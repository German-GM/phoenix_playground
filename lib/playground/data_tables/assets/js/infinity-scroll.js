/***
 * Excerpted from "Building Table Views with Phoenix LiveView",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit https://pragprog.com/titles/puphoe for more book information.
***/
export default {
  rootElement() {
    return (
      document.documentElement || document.body.parentNode || document.body
    );
  },
  scrollPosition() {
    const { scrollTop, clientHeight, scrollHeight } = this.rootElement();

    return ((scrollTop + clientHeight) / scrollHeight) * 100;
  },
  mounted() {
    this.threshold = 90;
    this.lastScrollPosition = 0;

    window.addEventListener("scroll", () => {
      const currentScrollPosition = this.scrollPosition();

      const isCloseToBottom =
        currentScrollPosition > this.threshold &&
        this.lastScrollPosition <= this.threshold;

      if (isCloseToBottom) this.pushEvent("load-more", {});

      this.lastScrollPosition = currentScrollPosition;
    });
  },
};
