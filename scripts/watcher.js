const chokidar = require("chokidar");
const fs = require("fs");
const path = require("path");

const sourceFolder = "\\app\\aspnetapp";
const destFolder = "\\inetpub\\wwwroot";

chokidar
  .watch(sourceFolder, {
    persistent: true,
    usePolling: true,
    interval: 300,
    binaryInterval: 500
  })
  .on("all", (event, sourceFilePath) => {
    const sourceFolderPath = path.dirname(sourceFilePath);
    const destFilePath = sourceFilePath.replace(sourceFolder, destFolder);
    const destFolderPath = sourceFolderPath.replace(sourceFolder, destFolder);

    console.log(
      event,
      sourceFilePath,
      sourceFolderPath,
      destFilePath,
      destFolderPath,
      fs.existsSync(destFolderPath)
    );

    if (!fs.existsSync(destFolderPath)) {
      fs.mkdirSync(
        destFolderPath,
        { recursive: true },
        err => err && console.log(err)
      );
    }

    if (fs.lstatSync(sourceFilePath).isFile()) {
      fs.copyFile(sourceFilePath, destFilePath, err => err && console.log(err));
    }
  })
  .on("error", err => err && console.log(err));
