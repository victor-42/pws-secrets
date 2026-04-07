import {Component, OnInit} from '@angular/core';
import {faLock, faStickyNote, faUserSecret, faKey, faFileImage, faInfoCircle} from "@fortawesome/free-solid-svg-icons";
import {faGitlab} from "@fortawesome/free-brands-svg-icons";

@Component({
    selector: 'app-home',
    templateUrl: './home.component.html',
    styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
    faKey = faKey;
    faNote = faStickyNote;
    faGitLab = faGitlab;
    faImageFile = faFileImage;
    faInfo = faInfoCircle;
    mobile: boolean = false;

    constructor() {
        window.onresize = () => this.mobile = window.innerWidth <= 736;
        if (window.screen.width <= 736) {
            this.mobile = true;
        }
    }

    ngOnInit(): void {
    }

}
