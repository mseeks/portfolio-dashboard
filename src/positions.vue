<template>
<ul id="positions">
  <li class="headers">
    <span class="stock">Stock</span>
    <span class="signal_preview"></span>
    <span class="gain">Gain / Loss</span>
    <span class="allocation">Share</span>
  </li>
  <position v-for="position of shared.positions" v-bind:position="position"></position>
</ul>
</template>

<script>
import position from './position.vue'
import store from './store'

var currency_formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
});

export default {
  name: 'positions',
  components: {
    position
  },
  created() {
    this.fetch_data();
  },
  data() {
    return {
      shared: store.state
    }
  },
  methods: {
    fetch_data() {
      $.get('https://apps.msull92.com/data/portfolio/positions', response => {
        this.shared.positions = response.positions;
      });
    }
  },
  mounted: function () {
    this.fetch_data();
  },
  watch: {
    'shared.heartbeat' () {
      this.fetch_data();
    }
  }
}
</script>

<style lang="scss">
ul#positions {
  box-sizing: border-box;
  font-size: 0.75em;
  list-style-type: none;
  margin: 15px 0;
  padding: 0 15px 0 0;
  width: 50%;

  @media (max-width: 576px) {
    margin: 0 0 25px;
    padding: 0 15px;
    width: 100%;
  }

  li.headers {
    border-bottom: 1px solid transparentize(#4B515D, 0.75);
    display: flex;
    margin-bottom: 10px;
    padding-bottom: 10px;

    span {
      font-weight: bold;
      width: 45%;

      &.allocation {
        text-align: right;
        width: 15%;
      }

      &.signal_preview {
        text-align: right;
        width: 10%;
      }

      &.signal_preview {
        text-align: center;
      }

      &.gain {
        text-align: right;
        width: 35%;
      }
    }
  }
}
</style>
