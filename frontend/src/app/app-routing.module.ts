import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import {AppComponent} from "./app.component";
import {GetSecretComponent} from "./views/get-secret/get-secret.component";
import {AddSecretComponent} from "./views/add-secret/add-secret.component";
import {HomeComponent} from "./views/home/home.component";
import {InfoComponent} from "./views/info/info.component";

const routes: Routes = [
    {
        path:"",
        redirectTo: "/home",
        pathMatch: "full"
    },
    {
        path:"home",
        component: HomeComponent,
    },
    {
        path:"info",
        component: InfoComponent,
    },
    {
        path:"note",
        component: AddSecretComponent,
        data: {
            type: 'note'
        }
    },
    {
        path:"credentials",
        component: AddSecretComponent,
        data: {
            type: 'login'
        }
    },
    {
        path:"image",
        component: AddSecretComponent,
        data: {
            type: 'image'
        }
    },
    {
        path:"get",
        component: GetSecretComponent,
    },
    {
        path:"**",
        redirectTo: '/note'
    }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
