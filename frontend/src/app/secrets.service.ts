import {EventEmitter, Injectable} from "@angular/core";
import {HttpClient, HttpHeaders, HttpParams} from "@angular/common/http";
import {environment} from "../environments/environment";
import {Observable, Subject} from "rxjs";

export interface CreateSecretResponse {
    msg: string
}

export interface NoteFields {
    type: string,
    note: string
}

export interface ImageFields {
    type: string,
    image: File,
    note: string
}


export interface LoginFields {
    type: string,
    username: string,
    password: string
}

@Injectable({providedIn: 'root'})
export class SecretsService {
    public scrollDownEvent: Subject<boolean> = new Subject<boolean>();
    constructor(
        private _http: HttpClient
    ) {}

    create(data: NoteFields|LoginFields|ImageFields, timedelta: number) {
        if (data.type == 'image') {

            let formData:FormData = new FormData();
            // @ts-ignore
            formData.append('image', data.image, data.image.name);
            // @ts-ignore
            formData.append('note', data.note);
            formData.append('type', 'image');

            let headers = new HttpHeaders();
            headers.append('Content-Type', undefined);

            return this._http.post<CreateSecretResponse>(environment.api_image, formData, {
                headers: headers,
            })
        } else {
            return this._http.post<CreateSecretResponse>(environment.api, {
                ...data,
                time_delta: timedelta
            })
        }

    }

    get(msg: string, image: string) {
        if (image == '1') {
            return this._http.get<NoteFields|LoginFields>(environment.api_image, {
                params: new HttpParams().set('msg', msg)
            })
        } else {
            return this._http.get<NoteFields|LoginFields>(environment.api, {
                params: new HttpParams().set('msg', msg)
            })
        }

    }
}
