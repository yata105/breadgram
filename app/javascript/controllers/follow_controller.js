import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { username: String };
  static targets = ["count"];

  toggle(event) {
    const checked = event.target.checked;
    const username = this.usernameValue;

    const url = `/follows` + (checked ? "" : `/destroy`);
    const method = checked ? "POST" : "DELETE";

    fetch(url, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getMetaValue("csrf-token")
      },
      body: JSON.stringify({ username: username })
    })
    .then(response => response.json())
    .then(data => {
      this.countTarget.textContent = data.followers_count + " followers";
      this.changeButtonText(checked);
    })
    .catch(error => {
      console.error("Failed to follow:", error);
    })
  }

  changeButtonText(checkedStatus) {
    const button = document.querySelector('#follow-button');
    button.innerHTML = checkedStatus ? "Unfollow" : "Follow";
  }

  getMetaValue(name) {
    const element = document.querySelector(`meta[name="${name}"]`)
    return element && element.getAttribute("content")
  }
}