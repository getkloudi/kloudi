<p align="center">
  <br />
  <a title="Kloudi a self-hosted universal command line for your tools" href="https://kloudi.tech">
    <img alt="Kloudi - Universal Command Line for tools" src="https://kloudi.tech/github-repo-banner.png"/>
  </a>
</p>

Kloud is a Universal Command Line that enables developers to enter commands and queries to search, view and perform actions on data from all their engineering tools. Some of the tools that we currently support out of the box are Sentry, Github Issue, Jira, Datadog, Rollbar, AWS etc.

## 🌟Features

  - All tools, data and actions connected and made available as a downloadable locally hosted desktop app. 100% secure and fast to use
  - Zero navigation and shuffling tools for fetching data.
  - Build and customize your workflows by writing simple markdown.
  - Current focussed on bug management workflow, saving debugging time of 40-60 mins per bug.
  - Productivity and ease like never before by bringing UI to CLI.

For more details, head to: https://kloudi.tech/

## 🚀Get-Started

### 🚧Prerequisites
 - macOSX 10.14
 - docker-compose and Docker for mac

 ### 💻TL;DR
 Run the command below to get started

 `
 bash -c "$(curl -L https://raw.githubusercontent.com/kloudi-tech/local/release/get_kloudi.sh)"
 `

### 📜Long Version

 - Download the latest macOSX app from https://github.com/kloudi-tech/local/releases.
 - Download the latest docker-compose setup from https://github.com/kloudi-tech/local/releases.
 - Run the command
 ` docker-compose --file kloudi-backend.yml up --remove-orphans --build `
   Wait for the containers to be up. First time setup usually takes about 2-3 mins to pull all the images and get everything working.
 -  Install and run the Kloudi app

 ## 👾Report-A-Bug
 Facing an issue, something is not working raise an issue
 [here](https://github.com/kloudi-tech/kloudi/issues) and we'll get back to you
 as soon as possible.
