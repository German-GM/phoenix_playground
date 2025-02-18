/***
 * Excerpted from "Building Table Views with Phoenix LiveView",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit https://pragprog.com/titles/puphoe for more book information.
***/
export default {
  addPongListener() {
    window.addEventListener("phx:pong", (event) => {
      console.log(event.type);
      console.log(event.detail.message);
    });
  },
  sendPing() {
    this.pushEvent("ping", { myVar: 1 });
  },
  mounted() {
    console.log("I'm alive!");
    this.addPongListener();
    this.sendPing();
  },
};
