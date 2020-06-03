import {Component} from '@angular/core';
import {Web3Service} from './services/web3.service';
import {FormBuilder} from '@angular/forms';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'ethdapp';

  createBadgeForm;
  addCreatorForm;
  removeCreatorForm;


  constructor(public web3: Web3Service, private formBuilder: FormBuilder) {
    this.createBadgeForm = this.formBuilder.group({
      metadataUrl: '',
    });

    this.addCreatorForm = this.formBuilder.group({
      address: '',
    });

    this.removeCreatorForm = this.formBuilder.group({
      address: '',
    });
  }

  onSubmit(badgeData) {
    console.log(badgeData.metadataUrl);
    this.web3.createBadge(badgeData.metadataUrl)
      .then((res) => {
        console.log(res);
        this.createBadgeForm.reset();
      }).catch((err) => {
      console.error(err);
    });
  }

  onAddCreatorSubmit(creatorData) {
    this.web3.addCreator(creatorData.address)
      .then((res) => {
        console.log(res);
        this.addCreatorForm.reset();
      }).catch((err) => {
      console.error(err);
    });
  }

  onRemoveCreatorSubmit(creatorData) {
    this.web3.removeCreator(creatorData.address)
      .then((res) => {
        console.log(res);
        this.removeCreatorForm.reset();
      }).catch((err) => {
      console.error(err);
    });
  }
}
