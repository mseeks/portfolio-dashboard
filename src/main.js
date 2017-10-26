import vue from 'vue'
import vue_router from 'vue-router'

vue.use(vue_router)

import app from './app.vue'

const router = new vue_router({
  routes: [
    { path: '/:period' }
  ]
})

new vue({
  el: '#app',
  router,
  render: h => h(app)
})
