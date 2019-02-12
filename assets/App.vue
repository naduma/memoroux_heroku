<template>
  <div id="app" class="container">
    <header class="navbar">
      <section class="navbar-section">
        <a href="/" class="navbar-brand mr-2">memoroux</a>
      </section>
      <section class="navbar-center">
        <button class="btn btn-primary" v-bind:disabled="isLoading" v-on:click="convert">convert</button>
      </section>
      <section class="navbar-section">
        <div class="form-group mr-2">
          <label class="form-radio form-inline">
            <input type="radio" name="type" value="html" v-model="type"
                   v-on:change="convert">
            <i class="form-icon"></i> HTML
          </label>
          <label class="form-radio form-inline">
            <input type="radio" name="type" value="pdf" v-model="type"
                   v-on:change="convert">
            <i class="form-icon"></i> PDF
          </label>
        </div>

        <a class="btn btn-link" target="_blank"
           title="Open in new window"
           v-bind:disabled="!isConverted" v-bind:href="viewUrl">
          <i class="icon external"></i>
        </a>
      </section>
    </header>

    <main class="columns col-gapless">
      <div class="column col-6">
        <textarea v-model="content"></textarea>
      </div>
      <div class="column col-6" v-bind:class="{ loading: isLoading, 'loading-lg': isLoading }">
        <iframe v-bind:src="viewUrlWithTs" />
      </div>
    </main>
  </div>
</template>


<script>
import axios from 'axios';
import uuid from 'uuid/v4';

// from https://asciidoctor.org/
const defaultContent = `= Hello, AsciiDoc!
Doc Writer <doc@example.com>

An introduction to http://asciidoc.org[AsciiDoc].

== First Section

* item 1
* item 2

[source,ruby]
puts "Hello, World!"
`;
  
const BLANK = 'about:blank';

export default {
  name: 'app',
  data: function () {
    return {
      id: uuid(),
      content: defaultContent,
      type: 'html',
      viewUrl: BLANK,
      viewUrlWithTs: BLANK,
      isConverted: false,
      isLoading: false
    }
  },
  methods: {
    convert: function() {
      this.isLoading = true;
      axios({
        method: 'post',
        url: '/convert',
        data: {
          id: this.id,
          content: this.content,
          type: this.type
        }
      }).then((response) => {
        this.viewUrl = response.data.url;
        this.viewUrlWithTs = `${this.viewUrl}?_=${Date.now()}`;
        this.isConverted = true;
      }).catch((error) => {
        this.isConverted = false;
        console.log(error);
      }).finally(() => this.isLoading = false);
    }
  }
};

</script>


<style lang="scss">
@import './node_modules/spectre.css/src/_variables.scss';
@import './node_modules/spectre.css/src/_mixins.scss';
@import './node_modules/spectre.css/src/_normalize.scss';
@import './node_modules/spectre.css/src/_base.scss';
@import './node_modules/spectre.css/src/_layout.scss';
@import './node_modules/spectre.css/src/_buttons.scss';
@import './node_modules/spectre.css/src/_typography.scss';
@import './node_modules/spectre.css/src/_navbar.scss';
@import './node_modules/spectre.css/src/_modals.scss';
@import './node_modules/spectre.css/src/_animations.scss';
@import './node_modules/spectre.css/src/utilities/_loading.scss';
@import './node_modules/spectre.css/src/_icons.scss';
@import './node_modules/spectre.css/src/_forms.scss';


$navbar-pad: .4rem;
$navbar-height: $control-size + $navbar-pad + $navbar-pad;

html, body, #app {
  height: 100%;
}
header {
  padding: $navbar-pad 0;
}
main {
  height: calc(100% - #{$navbar-height});
}

textarea, iframe {
  width: 100%;
  height: 99%;
  border: 1px solid $gray-color;
}
textarea {
  resize: none;
}
iframe {
  border-left: none;
}

.navbar-section .form-group {
  margin-bottom: 0 !important;
  margin-right: .8rem !important;
}

.external {
  background: url('data:image/svg+xml;base64,PHN2ZyBpZD0iaWNvbi1leHRlcm5hbCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHZpZXdCb3g9IjAgMCAxMjAgMTIwIiB4bWw6c3BhY2U9InByZXNlcnZlIj4NCjxwb2x5Z29uIGZpbGw9IiMwMjAyMDIiIHBvaW50cz0iMTIwLjA4OCwxNi42OTYgNjAuMjU2LDE2LjY5NyA2MC4yNTcsMC4wOTUgMTIwLjA5MiwwLjA5MSAiLz4NCjxyZWN0IHg9IjU1LjkxIiB5PSIyNC41NjIiIHRyYW5zZm9ybT0ibWF0cml4KDAuNzA3MSAtMC43MDcxIDAuNzA3MSAwLjcwNzEgMS4wODc3IDcwLjgwNjEpIiBmaWxsPSIjMDIwMjAyIiB3aWR0aD0iNjAuMjA5IiBoZWlnaHQ9IjE5LjA1NiIvPg0KPHBvbHlnb24gZmlsbD0iIzAyMDIwMiIgcG9pbnRzPSIxMTkuOTc1LDAuMTA3IDExOS45OTYsNTkuOTM4IDEwMy40MDgsNTkuOTUgMTAzLjM5MywwLjEwNCAiLz4NCjxyZWN0IHg9IjMiIHk9IjIzLjUiIGZpbGw9IiMwMjAyMDIiIHdpZHRoPSIxNyIgaGVpZ2h0PSI4NyIvPg0KPHJlY3QgeD0iODYuNDkiIHk9Ijc2LjA1OSIgZmlsbD0iIzAyMDIwMiIgd2lkdGg9IjE3IiBoZWlnaHQ9IjM2Ljk0MSIvPg0KPHJlY3QgeD0iMyIgeT0iMTYuNjkyIiBmaWxsPSIjMDIwMjAyIiB3aWR0aD0iNDAuNjU1IiBoZWlnaHQ9IjE3Ii8+DQo8cmVjdCB4PSIzIiB5PSI5NiIgZmlsbD0iIzAyMDIwMiIgd2lkdGg9IjEwMC40OSIgaGVpZ2h0PSIxNyIvPg0KPC9zdmc+') no-repeat center center / 100%;
}
</style>
