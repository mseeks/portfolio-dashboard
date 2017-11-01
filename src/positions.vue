<template>
<ul id="positions">
  <li class="headers">
    <span class="stock">Stock</span>
    <span class="gain">Gain / Loss</span>
    <span class="allocation">Share</span>
  </li>
  <position v-for="position of positions" v-bind:position="position"></position>
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
      positions: []
    }
  },
  computed: {
  },
  methods: {
    fetch_data() {
      $.get('https://apps.msull92.com/data/portfolio/positions', response => {
        this.positions = response.positions;
      });
    }
  },
  mounted: function () {
    this.fetch_data();

    this.interval = setInterval(function () {
      this.fetch_data();
    }.bind(this), 10000);
  },
  beforeDestroy: function(){
    clearInterval(this.interval);
  }
}
</script>

<style lang="scss">
ul#positions {
  list-style-type: none;
  padding: 0;
  width: 50%;

  li.headers {
    border-bottom: 1px solid transparentize(#4B515D, 0.75);
    display: flex;
    font-size: 0.75em;
    margin-bottom: 10px;
    padding-bottom: 10px;

    span {
      font-weight: bold;
      width: 40%;

      &.gain {
        text-align: right;
      }

      &.allocation {
        text-align: right;
        width: 20%;
      }
    }
  }
}
</style>
