const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// Serve static files from the 'public' directory
app.use(express.static('public'));

// Proxy any requests starting with /api to your backend service
app.use('/api/', createProxyMiddleware({
    target: 'http://backend:1993',
    changeOrigin: true,
    pathRewrite: {
        '^/api/': '/',  // rewrite path
    },
}));

const port = process.env.PORT || 3000;

app.listen(port, () => console.log(`Server is running at http://localhost:${port}`));
