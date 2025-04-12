import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { postId: Number };
  static targets = ["count"];

  toggle(event) {
    const checked = event.target.checked;
    const postId = this.postIdValue;

    const url = `/likes` + (checked ? "" : `/destroy`);
    const method = checked ? "POST" : "DELETE";

    fetch(url, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getMetaValue("csrf-token")
      },
      body: JSON.stringify({ post_id: postId })
    })
    .then(response => response.json())
    .then(data => {
      this.countTarget.textContent = data.likes_count;
    })
    .catch(error => {
      console.error("Failed to like:", error)
    })
  }

  getMetaValue(name) {
    const element = document.querySelector(`meta[name="${name}"]`);
    return element && element.getAttribute("content");
  }
}