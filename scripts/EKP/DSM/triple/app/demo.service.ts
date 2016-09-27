import {Injectable} from '@angular/core';
import {HTTP_PROVIDERS, Http, Response, Headers, RequestOptions} from "@angular/http";
import {Observable} from 'rxjs/Rx';

@Injectable()
export class DemoService {

    constructor(private http: Http) {
    }

    // read triple csv files
    getCharts() {
        return this.http.get('/app/triple.csv')
            .map(this.successData)
            .catch(this.handleError);
        // Uses Observable.forkJoin() to run multiple concurrent http.get() requests.
        // return Observable.forkJoin(
        // this.http.get('/app/node.json').map((res:Response) => res.json()),
        // this.http.get('/app/edge.json').map((res:Response) => res.json())
        // );
    }
    /**
     * success data return
     */
    private successData(res: Response) {
        var nodes = [];
        var nodeArray = [];
        var edges = [];
        var subject = '';
        var predicate = '';
        var object = '';
        var subjectIndex = '';
        var objectIndex = '';
        var arr = res._body.split("\n");
        for (var index in arr) // for acts as a foreach
        {
            var splitnode = arr[index].split(';');
            subject = splitnode[0].replace(/"/g, '');
            object = splitnode[2].replace(/"/g, '');
            predicate = splitnode[1].replace(/"/g, '');
            if(nodeArray.indexOf(subject)<0){
                nodeArray.push(subject);
            }
            if(nodeArray.indexOf(object)<0){
                nodeArray.push(object);
            }
            subjectIndex = nodeArray.indexOf(subject);
            objectIndex = nodeArray.indexOf(object);
            if(subjectIndex>=0 && objectIndex>=0){
                edges.push({
                    source: subjectIndex,
                    target: objectIndex,
                    predicate: predicate
                });
            }
        }
        for (var nodeindex in nodeArray) // for acts as a foreach
        {
            nodes.push({name:nodeArray[nodeindex]});
        }
        return {nodes:nodes,edges:edges};
    }
    /**
     * handling error
     */
    private handleError(error: any) {
        let errMsg = (error.message) ? error.message :
            error.status ? `${error.status} - ${error.statusText}` : 'Server error';
        console.error(errMsg); // log to console instead
        return Observable.throw(errMsg);
    }
}