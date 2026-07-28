"use strict";

const express = require("express");
const cors = require("cors");
const packageInfo = require("./package.json");

const app = express();

const PORT = process.env.PORT || 12008;
const applicationVersion =
  process.env.APP_VERSION || packageInfo.version || "unknown";

app.use(express.json());

/*
 * For this first lab, allow requests from every origin.
 *
 * Later, replace "*" with the exact S3 website or CloudFront URL.
 */
app.use(
  cors({
    origin: "*",
    methods: ["GET"],
  })
);

app.get("/", (req, res) => {
  res.json({
    application: "AWS CI/CD Backend",
    message: "The Node.js backend is running",
    endpoints: [
      "/api/status",
      "/api/hello",
      "/api/time",
      "/api/version",
    ],
  });
});

app.get("/api/status", (req, res) => {
  res.json({
    status: "UP",
    host: req.hostname,
  });
});

app.get("/api/hello", (req, res) => {
  res.json({
    message: "Hello from version 2 deployed by AWS github actions on ECS",
  });
});

app.get("/api/time", (req, res) => {
  res.json({
    serverTime: new Date().toISOString(),
  });
});

app.get("/api/version", (req, res) => {
  res.json({
    application: "aws-cicd-backend",
    version: applicationVersion,
  });
});

/*
 * Return JSON for unknown routes.
 */
app.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    path: req.originalUrl,
  });
});

/*
 * Basic Express error handler.
 */
app.use((error, req, res, next) => {
  console.error(error);

  res.status(500).json({
    error: "Internal Server Error",
  });
});

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend listening on port ${PORT}`);
});

/*
 * Allow systemd to stop the application cleanly.
 */
function shutdown(signal) {
  console.log(`${signal} received. Shutting down.`);

  server.close(() => {
    console.log("HTTP server stopped.");
    process.exit(0);
  });

  setTimeout(() => {
    console.error("Forced shutdown.");
    process.exit(1);
  }, 10000);
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));