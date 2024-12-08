// {
// //   "timeZone": "America/Chicago",
// //   "dependencies": {
// //     "enabledAdvancedServices": [
// //       {
// //         "userSymbol": "Drive",
// //         "serviceId": "drive",
// //         "version": "v2"
// //       }
// //     ]
// //   },
// //   "oauthScopes": [
// //     "https://www.googleapis.com/auth/drive",
// //     "https://www.googleapis.com/auth/drive.file",
// //     "https://www.googleapis.com/auth/script.scriptapp",
// //     "https://www.googleapis.com/auth/script.external_request",
// //     "https://www.googleapis.com/auth/spreadsheets",
// //     "https://www.googleapis.com/auth/drive.metadata.readonly"
// //   ],
// //   "exceptionLogging": "STACKDRIVER",
// //   "runtimeVersion": "V8"
// }


/**
 * Transfer ownership of a specific file to another user.
 * @param {string} fileId The ID of the file to transfer ownership.
 * @param {string} newOwnerEmail The email address of the new owner.
 */
function transferFileOwnership(fileId, newOwnerEmail) {
  try {
    const file = DriveApp.getFileById(fileId);
    Logger.log(`Current owner of file '${file.getName()}' is: ${file.getOwner().getEmail()}`);
    file.setOwner(newOwnerEmail);
    Logger.log(`Ownership of file '${file.getName()}' has been transferred to: ${newOwnerEmail}`);
  } catch (e) {
    Logger.log(`Error transferring ownership for file ID ${fileId}: ${e.message}`);
  }
}

/**
 * Transfer ownership of all files in the current user's drive to another user.
 * @param {string} newOwnerEmail The email address of the new owner.
 */
function transferAllFilesToUser(newOwnerEmail) {
  try {
    const files = DriveApp.getFiles(); // Get all files owned by the current user
    let transferredCount = 0;

    while (files.hasNext()) {
      const file = files.next();
      const fileName = file.getName();
      Logger.log(`Transferring ownership of file: ${fileName}`);
      try {
        file.setOwner(newOwnerEmail);
        transferredCount++;
      } catch (e) {
        Logger.log(`Error transferring ownership for file: ${fileName} - ${e.message}`);
      }
    }

    Logger.log(`Ownership of ${transferredCount} files has been transferred to: ${newOwnerEmail}`);
  } catch (e) {
    Logger.log(`Error transferring files: ${e.message}`);
  }
}

/**
 * Transfer ownership of all files owned by a departing user to a new user.
 * @param {string} departingUserEmail The email address of the departing user.
 * @param {string} newOwnerEmail The email address of the new owner.
 */
function transferOwnershipForDepartingUser(departingUserEmail, newOwnerEmail) {
  try {
    const files = DriveApp.getFilesByOwner(DriveApp.getUserByEmail(departingUserEmail)); // Get files owned by departing user
    let transferredCount = 0;

    while (files.hasNext()) {
      const file = files.next();
      const fileName = file.getName();

      Logger.log(`Transferring ownership of file: ${fileName}`);
      try {
        file.setOwner(newOwnerEmail);
        transferredCount++;
      } catch (e) {
        Logger.log(`Error transferring ownership for file: ${fileName} - ${e.message}`);
      }
    }

    Logger.log(`Ownership of ${transferredCount} files has been successfully transferred from ${departingUserEmail} to ${newOwnerEmail}`);
  } catch (e) {
    Logger.log(`Error transferring files for departing user: ${e.message}`);
  }
}

/**
 * Batch transfer file ownership from a Google Sheet.
 * Format:
 * | File ID            | New Owner Email       |
 * |--------------------|-----------------------|
 * | fileId12345        | newowner@example.com  |
 */
function batchTransferOwnership() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  const data = sheet.getDataRange().getValues();

  for (let i = 1; i < data.length; i++) {
    const fileId = data[i][0]; // File ID from column A
    const newOwnerEmail = data[i][1]; // New owner email from column B

    if (fileId && newOwnerEmail) {
      Logger.log(`Transferring ownership for file ID: ${fileId} to ${newOwnerEmail}`);
      transferFileOwnership(fileId, newOwnerEmail);
    } else {
      Logger.log(`Skipping row ${i + 1}: Missing file ID or owner email.`);
    }
  }
}

/**
 * Menu to choose between transferring specific files, an entire drive, or a departing user's files.
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu("Ownership Transfer")
    .addItem("Transfer Specific Files", "batchTransferOwnership")
    .addItem("Transfer Entire Drive", "promptTransferAllFilesToUser")
    .addItem("Transfer Departing User's Files", "promptDepartingUserTransfer")
    .addToUi();
}

/**
 * Prompt user for new owner email and transfer all files in their drive.
 */
function promptTransferAllFilesToUser() {
  const ui = SpreadsheetApp.getUi();
  const response = ui.prompt("Transfer Entire Drive", "Enter the email address of the new owner:", ui.ButtonSet.OK_CANCEL);

  if (response.getSelectedButton() === ui.Button.OK) {
    const newOwnerEmail = response.getResponseText().trim();
    if (newOwnerEmail) {
      Logger.log(`Starting transfer of all files to: ${newOwnerEmail}`);
      transferAllFilesToUser(newOwnerEmail);
    } else {
      Logger.log("No email address provided. Transfer canceled.");
    }
  } else {
    Logger.log("Transfer canceled by user.");
  }
}

/**
 * Prompt for departing user and new owner details, then transfer all files.
 */
function promptDepartingUserTransfer() {
  const ui = SpreadsheetApp.getUi();
  const departingUserResponse = ui.prompt(
    "Departing User",
    "Enter the email address of the departing user:",
    ui.ButtonSet.OK_CANCEL
  );

  if (departingUserResponse.getSelectedButton() === ui.Button.OK) {
    const departingUserEmail = departingUserResponse.getResponseText().trim();
    if (departingUserEmail) {
      const newOwnerResponse = ui.prompt(
        "New Owner",
        "Enter the email address of the new owner:",
        ui.ButtonSet.OK_CANCEL
      );

      if (newOwnerResponse.getSelectedButton() === ui.Button.OK) {
        const newOwnerEmail = newOwnerResponse.getResponseText().trim();
        if (newOwnerEmail) {
          Logger.log(`Starting transfer of all files from ${departingUserEmail} to ${newOwnerEmail}`);
          transferOwnershipForDepartingUser(departingUserEmail, newOwnerEmail);
        } else {
          Logger.log("No new owner email provided. Transfer canceled.");
        }
      }
    } else {
      Logger.log("No departing user email provided. Transfer canceled.");
    }
  } else {
    Logger.log("Transfer canceled by user.");
  }
}
