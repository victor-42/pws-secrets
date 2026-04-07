import {Component, ElementRef, OnInit, ViewChild} from '@angular/core';
import {
    faEnvelopeOpen,
    faFileImage,
    faHome,
    faImage,
    faInfoCircle,
    faKey,
    faStickyNote
} from "@fortawesome/free-solid-svg-icons";
import {environment} from "../environments/environment";
import {SecretsService} from "./secrets.service";
import {Observable} from "rxjs";
import {startWith} from "rxjs/operators";

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
    title = 'frontend';
    mobile: boolean = false;
    faKey = faKey;
    faNote = faStickyNote;
    faOpen = faEnvelopeOpen;
    faInfo = faInfoCircle;
    asset_dir = environment.static_dir;
    faHome = faHome;
    faImage = faFileImage;
    @ViewChild('content', {static: false}) private content: ElementRef;

    constructor(private secretsService: SecretsService) {
    }

    ngOnInit(): void {
        this.secretsService.scrollDownEvent.subscribe(val => this.scrollToBottom());
        window.onresize = () => this.mobile = window.innerWidth <= 736;
        if (window.screen.width <= 736) {
            this.mobile = true;
        }
    }

    scrollToBottom(): void {
        this.content.nativeElement.scroll({
            top: this.content.nativeElement.scrollHeight,
            left: 0,
            behavior: 'smooth'
        });
    }
}
