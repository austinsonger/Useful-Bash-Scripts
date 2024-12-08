#{
#  "timeZone": "America/Chicago", 
#  "dependencies": {},
#  "exceptionLogging": "STACKDRIVER",
#  "runtimeVersion": "V8",
#  "oauthScopes": [
#    "https://www.googleapis.com/auth/admin.reports.audit.readonly",
#    "https://www.googleapis.com/auth/spreadsheets",
#    "https://www.googleapis.com/auth/drive",
#    "https://www.googleapis.com/auth/gmail.send"
#  ]
#}


function dailyFileSharingReportForOrg() {
  const recipientEmail = "user@example.com"; 
  const domain = "yourdomain.com"; 
  const sharedDriveName = "Shared Drive Name"; 
  const sheetName = "External File Sharing Log"; 

  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(today.getDate() - 1);

  const startTime = yesterday.toISOString(); // Start of the day (UTC)
  const endTime = today.toISOString(); // End of the day (UTC)

  const report = [];

  try {
    // Get Drive activity logs for the specified period
    const activities = AdminReports.Activities.list('all', 'drive', {
      startTime: startTime,
      endTime: endTime,
    });

    if (activities && activities.items) {
      activities.items.forEach(activity => {
        if (activity.events) {
          activity.events.forEach(event => {
            if (event.name === 'acl_change' && event.parameters) {
              const parameters = event.parameters;
              const fileName = parameters.find(p => p.name === 'doc_title')?.value;
              const fileId = parameters.find(p => p.name === 'target_id')?.value;
              const sharedWith = parameters.find(p => p.name === 'added_permission')?.value;
              const internalUser = activity.actor?.email; // Internal user who performed the action

              // Check if the file was shared with an external entity
              if (sharedWith && !sharedWith.endsWith(`@${domain}`)) {
                const fileUrl = `https://drive.google.com/file/d/${fileId}`;
                report.push({
                  fileName: fileName || "Unknown File Name",
                  fileUrl,
                  sharedWith,
                  internalUser: internalUser || "Unknown",
                });
              }
            }
          });
        }
      });
    }

    // Write data to Google Sheet
    if (report.length > 0) {
      const sheet = getOrCreateSheet(sharedDriveName, sheetName);
      const sheetData = report.map(item => [
        new Date().toLocaleString(), // Timestamp
        item.fileName,
        item.fileUrl,
        item.sharedWith,
        item.internalUser,
      ]);
      sheet.getRange(sheet.getLastRow() + 1, 1, sheetData.length, sheetData[0].length).setValues(sheetData);
    }

    // Generate the email report
    let emailBody = "The following files were shared with external entities today:\n\n";

    if (report.length > 0) {
      report.forEach(item => {
        emailBody += `File Name: ${item.fileName}\n`;
        emailBody += `File URL: ${item.fileUrl}\n`;
        emailBody += `Shared With: ${item.sharedWith}\n`;
        emailBody += `Shared By: ${item.internalUser}\n\n`;
      });
    } else {
      emailBody = "No external file sharing detected today.";
    }

    GmailApp.sendEmail(recipientEmail, "Daily External File Sharing Report", emailBody);
  } catch (error) {
    Logger.log(`Error: ${error.message}`);
    GmailApp.sendEmail(recipientEmail, "Daily External File Sharing Report - Error", `An error occurred: ${error.message}`);
  }
}

function getOrCreateSheet(driveName, sheetName) {
  const drives = DriveApp.getDrives();
  let sharedDrive;
  while (drives.hasNext()) {
    const drive = drives.next();
    if (drive.getName() === driveName) {
      sharedDrive = drive;
      break;
    }
  }

  if (!sharedDrive) {
    throw new Error(`Shared Drive "${driveName}" not found.`);
  }

  const files = DriveApp.getFolderById(sharedDrive.getId()).getFilesByName(sheetName);
  let spreadsheet;
  if (files.hasNext()) {
    spreadsheet = SpreadsheetApp.open(files.next());
  } else {
    // Create new spreadsheet in the Shared Drive
    spreadsheet = SpreadsheetApp.create(sheetName);
    DriveApp.getFileById(spreadsheet.getId()).moveTo(DriveApp.getFolderById(sharedDrive.getId()));
    // Set up the header row
    const sheet = spreadsheet.getActiveSheet();
    sheet.appendRow(["Timestamp", "File Name", "File URL", "Shared With", "Shared By"]);
  }
  return spreadsheet.getActiveSheet();
}
