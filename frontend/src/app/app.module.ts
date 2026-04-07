import {BrowserModule} from '@angular/platform-browser';
import {CUSTOM_ELEMENTS_SCHEMA, NgModule} from '@angular/core';

import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';
import {AddSecretComponent} from './views/add-secret/add-secret.component';
import {GetSecretComponent} from './views/get-secret/get-secret.component';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import {IgxBottomNavModule, IgxTabPanelComponent} from "igniteui-angular";
import {HttpClientModule} from "@angular/common/http";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {CommonModule} from "@angular/common";
import {MatInputModule} from "@angular/material/input";
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';
import {MatButtonModule} from "@angular/material/button";
import {MatIconModule} from "@angular/material/icon";
import {MatProgressSpinnerModule} from "@angular/material/progress-spinner";
import { InfoDialogComponent } from './views/info-dialog/info-dialog.component';
import {MatDialogModule} from "@angular/material/dialog";
import {ClipboardModule} from "ngx-clipboard";
import {MatOptionModule} from "@angular/material/core";
import {MatSelectModule} from "@angular/material/select";
import { HomeComponent } from './views/home/home.component';
import {MatCardModule} from "@angular/material/card";
import {MatProgressBarModule} from "@angular/material/progress-bar";
import { InfoComponent } from './views/info/info.component';
import {MatExpansionModule} from "@angular/material/expansion";

@NgModule({
    declarations: [
        AppComponent,
        AddSecretComponent,
        GetSecretComponent,
        InfoDialogComponent,
        HomeComponent,
        InfoComponent,
    ],
    imports: [
        CommonModule,
        BrowserModule,
        AppRoutingModule,
        BrowserAnimationsModule,
        IgxBottomNavModule,
        HttpClientModule,
        FormsModule,
        ReactiveFormsModule,
        MatInputModule,
        MatButtonModule,
        FontAwesomeModule,
        MatIconModule,
        MatProgressSpinnerModule,
        MatDialogModule,
        ClipboardModule,
        MatOptionModule,
        MatSelectModule,
        MatCardModule,
        MatProgressBarModule,
        MatExpansionModule,
    ],
    providers: [],
    bootstrap: [AppComponent],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class AppModule {
}
