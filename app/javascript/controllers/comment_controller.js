import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "hintText", "postId"];

  async submitComment(event) {
    event.preventDefault();
    const textarea = this.textareaTarget;
    const hintText = this.hintTextTarget;
    const postId = this.postIdTarget.value;

    if (!textarea.value.trim()) return;

    const response = await fetch(`/posts/${postId}/comments`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getMetaValue("csrf-token"),
      },
      body: JSON.stringify({ comment: { value: textarea.value } }),
    });

    const data = await response.json();

    if (data.success) {
      this.addComment(data.comment);
      textarea.value = "";
      hintText.textContent = "0/200";
    } else {
      alert("Error: " + data.errors.join(", "));
    }
  }

  addComment(comment) {
    const commentList = document.querySelector("#comments-list");
    const commentItem = document.createElement("div");
    commentItem.classList.add("comment");
    commentItem.dataset.commentId = comment.id;
    commentItem.innerHTML = `
      <div class="post-info">
        <img src="${comment.avatar_url}" alt="profile image" class="profile-image">
        <div class="post-profile-date-likes">
          <div class="post-profile-date">
            <div class="post-profile">
              ${comment.username}
            </div>
            <div class="comment-date">
              ${comment.date}
              <img src="${comment.delete_url}" alt="delete" class="delete-button" data-action="click->comment#deleteComment">
            </div>
          </div>
        </div>
      </div>
      <div class="post-description">
        ${comment.value}
      </div>
    `;
    commentList.prepend(commentItem);
  }

  async deleteComment(event) {
    const commentElem = event.target.parentNode.parentNode.parentNode.parentNode.parentNode;
    const commentId = commentElem.dataset.commentId;
    
    console.log(commentId);
    const response = await fetch(`/posts/${this.postIdTarget.value}/comments/${commentId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": this.getMetaValue("csrf-token"),
      },
    });
  
    const data = await response.json();
    if (data.success) {
      if (commentElem) commentElem.remove();
    } else {
      alert("Failed to delete comment.");
    }

  }

  getMetaValue(name) {
    const element = document.querySelector(`meta[name="${name}"]`)
    return element && element.getAttribute("content")
  }
}
