import {Component, OnInit} from '@angular/core';
import {ActivatedRoute} from "@angular/router";
import {LoginFields, NoteFields, SecretsService} from "../../secrets.service";
import {InfoDialogComponent} from "../info-dialog/info-dialog.component";
import {MatDialog} from "@angular/material/dialog";
import {environment} from "../../../environments/environment";

@Component({
    selector: 'app-get-secret',
    templateUrl: './get-secret.component.html',
    styleUrls: ['./get-secret.component.scss']
})
export class GetSecretComponent implements OnInit {
    title_type: string = 'Secret';
    msg: string = null;
    msg_decrypted: NoteFields | LoginFields = null;
    loading: boolean = false;
    env = environment;
    image: string = '0';

    constructor(private _route: ActivatedRoute, private _secretsService: SecretsService, private _dialog: MatDialog) {
    }

    ngOnInit() {
        // Get encrypted message ID from queryparams
        this._route.queryParams.subscribe(params => {
            if (params.msg) {
                this.msg = params.msg;
                this.image = params.image;
                console.warn(params.image);
                this.getMessage(this.msg);
            }
        });
    }

    getMessage(id: string) {
        this.loading = true;
        // Get Message from Server
        this._secretsService.get(id, this.image).subscribe(data => {
                this.msg_decrypted = data;
                switch (data.type) {
                    case 'note':
                        this.title_type = 'Note';
                        break;
                    case 'login':
                        this.title_type = 'Login';
                        break;
                    case 'image':
                        this.title_type = 'Image';
                        break;
                }
                this.loading = false;
            },
            error => {
                this._dialog.open(InfoDialogComponent, {
                    data: {
                        title: 'Expired',
                        text: 'The message is invalid or expired.'
                    }
                });
                this.loading = false;
            }
        )
    }
}
