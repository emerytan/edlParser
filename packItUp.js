"use strict"

const builder = require("electron-builder")

// Promise is returned
builder.build({
  config: {
    "AppId": "com.electron.bashtag",
    "category": "public.app-category.utilities",
    "target": "pkg"
  }
})
  .then(() => {
    // handle result
  })
  .catch((error) => {
    // handle error
  })







