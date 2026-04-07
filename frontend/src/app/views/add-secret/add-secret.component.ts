import {Component, OnInit} from '@angular/core';
import {ActivatedRoute} from "@angular/router";
import {FormControl, FormGroup, Validators} from "@angular/forms";
import {faEye, faEyeSlash} from "@fortawesome/free-solid-svg-icons";
import {SecretsService} from "../../secrets.service";
import {environment} from "../../../environments/environment";
import {MatDialog} from "@angular/material/dialog";
import {InfoDialogComponent} from "../info-dialog/info-dialog.component";

@Component({
    selector: 'app-add-secret',
    templateUrl: './add-secret.component.html',
    styleUrls: ['./add-secret.component.scss']
})
export class AddSecretComponent implements OnInit {
    maxFileSize: number = 18874368;
    type: string;
    title: string;
    noteForm: FormGroup;
    loginForm: FormGroup;
    imageForm: FormGroup;
    passwordHide: boolean = true;
    msg: string = null;
    loading: boolean = false;
    timeDeltas = [
        {
            value: 86400,
            viewValue: '24h'
        },
        {
            value: 172800,
            viewValue: '48h'
        },
        {
            value: 259200,
            viewValue: '72h'
        }
    ];
    selectedTimedelta: number = 86400;
    private imageFile: File;

    constructor(private route: ActivatedRoute, private secretsService: SecretsService, private _dialog: MatDialog) {
    }

    ngOnInit() {
        // Initialising forms
        this.loginForm = new FormGroup({
            username: new FormControl(''),
            password: new FormControl(''),
        });

        this.noteForm = new FormGroup({
            note: new FormControl('')
        });

        this.imageForm = new FormGroup({
            note: new FormControl(''),
            image: new FormControl('')
        });

        // Get Form Type from rout data
        this.title = '<strong>Encrypt</strong> ';
        this.route
            .data
            .subscribe(d => {
                this.type = d.type;
                if (d.type == 'note') {
                    this.title += 'Note<br>'
                } else if (d.type == 'login') {
                    this.title += 'Credentials<br>'
                } else if (d.type == 'image') {
                    this.title += 'Image<br>'
                } else {
                    this.title = 'Looks like you`re wrong.'
                }
            });
    }

    submit() {
        // Print Error Dialog when forms empty
        if ((this.type == 'note' && !this.noteForm.value.note) ||
            (this.type == 'image' && !this.imageFile) ||
            (this.type == 'login' && !this.loginForm.value.username && !this.loginForm.value.password)) {
            this._dialog.open(InfoDialogComponent, {
                data: {
                    title: 'No data',
                    text: 'Please provide any data to encrypt.'
                }
            });
            return
        }

        // Get Encrypted Message
        this.loading = true;
        var response;
        if (this.type == 'note') {
            response = this.secretsService.create({type: this.type, ...this.noteForm.value}, this.selectedTimedelta)
        } else if (this.type == 'login') {
            response = this.secretsService.create({type: this.type, ...this.loginForm.value}, this.selectedTimedelta)
        } else if (this.type == 'image') {
            response = this.secretsService.create({
                type: this.type,
                note: this.imageForm.value.note?this.imageForm.value.note:'',
                image: this.imageFile
            }, this.selectedTimedelta)
        }
        response.subscribe(r => {
                this.msg = environment.msg_prefix + r.msg + (this.type == 'image'? '&image=1':'&image=0');
                this.loading = false;
                this.noteForm.reset();
                this.loginForm.reset();
                this.secretsService.scrollDownEvent.next(true)
            },
            error => {
                // Error Dialog on Http Error
                this.loading = false;
                this._dialog.open(InfoDialogComponent, {
                    data: {
                        title: 'Error!',
                        text: 'Can\'t connect to the server,<br>please try again later.'
                    }
                })
            })
    }

    onFileSelected(files: FileList) {
        if (files) {
            const file = files.item(0);
            if (file.size >= this.maxFileSize) {
                this._dialog.open(InfoDialogComponent, {
                    data: {
                        title: 'Image too big',
                        text: 'The upload limit is 20 MByte, please use a smaller image.'
                    }
                })
            } else {
                this.imageFile = file;
            }
        }
    }

    generatePassword() {
        this.loginForm.patchValue({password: password_generator(12)})
    }
}

// Password generator function => https://stackoverflow.com/questions/1497481/javascript-password-generator By hajikelist
function password_generator( len ) {
    let length = (len)?(len):(10);
    let string = "abcdefghijklmnopqrstuvwxyz"; //to upper
    let numeric = '0123456789';
    let punctuation = '!#_+?,.-=';
    let password = "";
    let character = "";
    let crunch = true;
    while( password.length<length ) {
        let entity1 = Math.ceil(string.length * Math.random()*Math.random());
        let entity2 = Math.ceil(numeric.length * Math.random()*Math.random());
        let entity3 = Math.ceil(punctuation.length * Math.random()*Math.random());
        let hold = string.charAt( entity1 );
        hold = (password.length%2==0)?(hold.toUpperCase()):(hold);
        character += hold;
        character += numeric.charAt( entity2 );
        character += punctuation.charAt( entity3 );
        password = character;
    }
    password=password.split('').sort(function(){return 0.5-Math.random()}).join('');
    return password.substr(0,len);
}
