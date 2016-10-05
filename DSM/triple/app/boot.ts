/**bootstrap to import form,http and other required module  */
import {bootstrap} from '@angular/platform-browser-dynamic';
import { FormsModule }   from '@angular/forms';
import {HTTP_PROVIDERS} from '@angular/http';
import {AppComponent} from './app.component';
import {DemoService} from './demo.service';

bootstrap(AppComponent, [
  HTTP_PROVIDERS,
  FormsModule,
  DemoService
]);