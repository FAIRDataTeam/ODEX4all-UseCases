import {Component, Pipe, PipeTransform} from '@angular/core';
import { CORE_DIRECTIVES, NgClass, FORM_DIRECTIVES, Control, ControlGroup, FormBuilder, Validators} from '@angular/common';
import {DemoService} from './demo.service';
import {Observable} from 'rxjs/Rx';
import 'rxjs/add/operator/map'
import {KeysPipe} from './pipe'
import { Node } from './node';
import { Edge } from './edge';

@Component({
    selector: 'demo-app',
    pipes: [KeysPipe],
    template: `<div id="graph"></div>
                <div class="search">
                    <form class="form-control">
                        <div>
                            <label>Predicate: </label>
                            <input [(ngModel)]="predicate" placeholder="predicate"/>
                            <button (click)="searchData()">Search</button>
                        </div>
                    </form>
                </div>
                <table border="1px" cell-padding="3px" cell-spacing="3px">
                    <tr>
                        <th>Subject</th>
                        <th>Predicate</th>
                        <th>Object</th>
                    </tr>
                    <tr *ngFor='let key of edges | keys'>
                        <td>{{key.value.source.name}}</td>
                        <td>{{ key.value.predicate }}</td>
                        <td>{{key.value.target.name}}</td>
                    </tr>
                </table>`
})

export class AppComponent {
    nodes: Node[];
    edges: Edge[];
    constructor(private _demoService: DemoService) {
        this.alledges = [];
        this.nodes = [];
    }
    /**
     * init function
     */
    ngOnInit() {
        this.getCharts();
    }
    /**
     * get chart data
     */
    getCharts() {
        this._demoService.getCharts().subscribe(
            data => {
                this.alledges = data.edges;
                this.allnodes = data.nodes;
                this.drawChart(data);
            }
        );
    }
    /**
     * draw chart
     */
    drawChart(data) {
        this.nodes = data.nodes;
        this.edges = data.edges;
            var w = 1000;
            var h = 600;
            var linkDistance = 200;
            var bbox = {};
            var rx = 0;
            var ry = 0;
            var colors = d3.scale.category10();
            d3.select("svg").remove();
            var svg = d3.select("#graph").append("svg").attr({ "width": '100%', "height": '100%' ,class:'graphcla'});
            var force = d3.layout.force()
                .nodes(this.nodes)
                .links(this.edges)
                .size([w, h])
                .linkDistance([linkDistance])
                .charge([-500])
                .theta(0.1)
                .gravity(0.05)
                .start();
            var edges = svg.selectAll("line")
                .data(this.edges)
                .enter()
                .append("line")
                .attr("id", function (d, i) { return 'edge' + i })
                .attr('marker-end', 'url(#arrowhead)')
                .style("stroke", "#ccc")
                .style("pointer-events", "none");

            var nodes = svg.selectAll("circle")
                .data(this.nodes)
                .enter()
                .append("circle")
                .attr({ "r": 15 })
                .style("fill", function (d, i) { return colors(i); })
                .call(force.drag)


            var nodelabels = svg.selectAll(".nodelabel")
                .data(this.nodes)
                .enter()
                .append("text")
                .attr({
                    "x": function (d) { return d.x; },
                    "y": function (d) { return d.y; },
                    "class": "nodelabel",
                    "stroke": "black"
                })
                .text(function (d) { return d.name; });

            var edgepaths = svg.selectAll(".edgepath")
                .data(this.edges)
                .enter()
                .append('path')
                .attr({
                    'd': function (d) { return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y },
                    'class': 'edgepath',
                    'fill-opacity': 0,
                    'stroke-opacity': 0,
                    'fill': 'blue',
                    'stroke': 'red',
                    'id': function (d, i) { return 'edgepath' + i }
                })
                .style("pointer-events", "none");

            var edgelabels = svg.selectAll(".edgelabel")
                .data(this.edges)
                .enter()
                .append('text')
                .style("pointer-events", "none")
                .attr({
                    'class': 'edgelabel',
                    'id': function (d, i) { return 'edgelabel' + i },
                    'dx': 80,
                    'dy': 0,
                    'font-size': 10,
                    'fill': '#aaa'
                });

            edgelabels.append('textPath')
                .attr({
                    'font-size': 16,
                    'xlink:href': function (d, i) { return '#edgepath' + i }
                })
                .style("pointer-events", "none")
                .text(function (d, i) { return d.predicate });


            svg.append('defs').append('marker')
                .attr({
                    'id': 'arrowhead',
                    'viewBox': '-0 -5 10 10',
                    'refX': 25,
                    'refY': 0,
                    //'markerUnits':'strokeWidth',
                    'orient': 'auto',
                    'markerWidth': 10,
                    'markerHeight': 10,
                    'xoverflow': 'visible'
                })
                .append('svg:path')
                .attr('d', 'M 0,-5 L 10 ,0 L 0,5')
                .attr('fill', '#ccc')
                .attr('stroke', '#ccc');


            force.on("tick", function () {

                edges.attr({
                    "x1": function (d) { return d.source.x; },
                    "y1": function (d) { return d.source.y; },
                    "x2": function (d) { return d.target.x; },
                    "y2": function (d) { return d.target.y; }
                });

                nodes.attr({
                    "cx": function (d) { return d.x; },
                    "cy": function (d) { return d.y; }
                });

                nodelabels.attr("x", function (d) { return d.x; })
                    .attr("y", function (d) { return d.y; });

                edgepaths.attr('d', function (d) {
                    var path = 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y;
                    //console.log(d)
                    return path
                });

                edgelabels.attr('transform', function (d, i) {
                    if (d.target.x < d.source.x) {
                        var bbox = this.getBBox();
                        rx = bbox.x + bbox.width / 2;
                        ry = bbox.y + bbox.height / 2;
                        return 'rotate(180 ' + rx + ' ' + ry + ')';
                    }
                    else {
                        return 'rotate(0)';
                    }
                });
            });

    }
    /**
     * search by predicate
     */
    searchData(){
        if(this.predicate!==undefined && this.predicate!==null && this.predicate!==''){
            var edgeArr = [];
            for(let i = 0; i <this.alledges.length; i++){
                if(this.predicate==this.alledges[i]['predicate']){
                    edgeArr.push(this.alledges[i]);
                }
            }
            this.edges = edgeArr;
        }
        else{
            this.edges = this.alledges;
        }
        var nodeArr = [];
        for(let i = 0; i <this.edges.length; i++){
            if(nodeArr.indexOf(this.edges[i].source)<0){
                nodeArr.push(this.edges[i].source);
            }
            if(nodeArr.indexOf(this.edges[i].target)<0){
                nodeArr.push(this.edges[i].target);
            }
        }
        this.nodes = nodeArr;
        this.drawChart({nodes:this.nodes,edges:this.edges})
    }
}
/**
 * import pipe for getting foreach loop key
 */
@Pipe({ name: 'keys' })
export class KeysPipe implements PipeTransform {
    transform(value, args: string[]): any {
        let keys = [];
        for (let key in value) {
            keys.push({ key: key, value: value[key] });
        }
        return keys;
    }
}