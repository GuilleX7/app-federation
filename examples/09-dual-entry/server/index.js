const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Serve parent/dist at the root path
app.use(express.static(path.join(__dirname, '../parent/dist')));

// Serve child/dist at /apps/child/
app.use('/apps/child', express.static(path.join(__dirname, '../child/dist')));

app.listen(PORT, () => {
  console.log(`Reverse proxy server running on http://localhost:${PORT}`);
  console.log(`- Parent app: http://localhost:${PORT}/`);
  console.log(`- Child app: http://localhost:${PORT}/apps/child/`);
});
