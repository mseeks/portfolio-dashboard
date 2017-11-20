<template>
<ul id="periods" v-bind:class="portfolio_change_class">
  <li><router-link to="/1d">1D</router-link></li>
  <li><router-link to="/1w">1W</router-link></li>
  <li><router-link to="/1m">1M</router-link></li>
  <li><router-link to="/3m">3M</router-link></li>
  <li><router-link to="/1y">1Y</router-link></li>
  <li><router-link to="/all">ALL</router-link></li>
</ul>
</template>

<script>
import store from './store'

export default {
  name: 'periods',
  data() {
    return {
      shared: store.state
    }
  },
  computed: {
    portfolio_change_class() {
      return {
        is_positive: (this.shared.raw_portfolio_change > 0),
        is_neutral: (this.shared.raw_portfolio_change == 0),
        is_negative: (this.shared.raw_portfolio_change < 0)
      };
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.params.period != null) {
        this.shared.period = to.params.period;
      }
    },
  }
}
</script>

<style lang="scss">
ul#periods {
  display: flex;
  justify-content: flex-end;
  list-style-type: none;
  padding: 0;
  width: 50%;

  @media (max-width: 576px) {
    margin-bottom: 0;
    order: 1;
    width: 100%;
  }

  li {
    align-items: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin: 0 10px;
    vertical-align: middle;

    a {
      color: #4B515D;
      opacity: 0.75;
      text-decoration: none;
      transition: ease 0.25s;

      &.router-link-active,
      &:hover {
        opacity: 1.0;
      }
    }
  }

  li a.router-link-active {
    transition: color 0.25s;
  }

  &.is_positive li a.router-link-active {
    color: #98c379;
  }

  &.is_neutral li a.router-link-active {
    color: #e5c07b;
  }

  &.is_negative li a.router-link-active {
    color: #e05252;
  }
}
</style>
