/** @type {import('tailwindcss').Config} */
module.exports = {
  css: './app/assets/tailwind/application.css',
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}