{
 source: {
  name: "docker-build-check",
  url: "https://docs.docker.com/reference/build-checks/",
},
severity: "WARNING",
diagnostics: .warnings | map({
  message: .description,
  location: {
    "path": $ENV.DOCKER_FILE_PATH,
    "range": {
      "start": {
        "line": .location.ranges[].start.line
      },
      "end": {
        "line": .location.ranges[].end.line
      },
    },
  },
  severity: "WARNING",
  code: {
    "value": .ruleName,
    "url": .url,
  },
})
}

