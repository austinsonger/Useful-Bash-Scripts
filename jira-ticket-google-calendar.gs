/*
TO-DO:
- [X] Modularize Create New Function parsePayload
- [X] Modularize Create New Function constructEventDetails
- [X] Modularize Create New Function createCalendarEvent
- [X] Make Jira Ticket Reporter also the Google Calendar Event Creator 
- [X] Automatically add the Ticket URL into the Calendar Event Description
- [ ] Make it sync bi-directional sync 
- [ ] Separate out the global constants into a separate file "Constants.gs"
- [ ] Separate out the Calendar scheduling functions into a separate file "CalendarUtils.gs"
*/

// =========POWER ON OR OFF SWITCH
const SCRIPT_ENABLED = true;
// ==============================

// CONSTANTS
const CALENDAR_ID = '<PLACEHOLDER>@group.calendar.google.com';
const EVENT_DURATION_HOURS = 2; // Duration of the event in hours
const JIRA_INSTANCE_URL = 'https://<PLACEHOLDER>.atlassian.net'; 
const ENGINEERS = "name@example.com,name@example.com,name@example.com"; 

// Function to parse the payload from the request
function parsePayload(payload) {a
  return {
    issueKey: payload.issue.key,
    issueSummary: payload.issue.fields.summary,
    issueDescription: payload.issue.fields.description,
    customDate: payload.issue.fields.customfield_12127,
    companyName: payload.issue.fields.customfield_11831,
    customerId: payload.issue.fields.customfield_12128,
    reporterEmail: payload.issue.fields.reporter ? payload.issue.fields.reporter.emailAddress : null
  };
}

// Function to construct event details
function constructEventDetails(issueKey, issueSummary, issueDescription, companyName, customerId) {
  const issueUrl = `${JIRA_INSTANCE_URL}/browse/${issueKey}`;
  const eventTitle = `${issueKey} - ${companyName ? companyName + ' - ' : ''}${issueSummary} (Customer ID: ${customerId})`;
  const eventDescription = `Jira Issue Key: ${issueKey}\n\n${issueDescription}\n\nJira Ticket URL: ${issueUrl}\n\nCustomer ID: ${customerId}`;

  return { eventTitle, eventDescription };
}

// Function to create a calendar event
function createCalendarEvent(calendarId, eventDetails, startDate, endDate, guests) {
  const calendar = CalendarApp.getCalendarById(calendarId);
  return calendar.createEvent(eventDetails.eventTitle, startDate, endDate, {
    description: eventDetails.eventDescription,
    guests: guests
  });
}

// Main function to handle POST request
function doPost(e) {
  if (!SCRIPT_ENABLED) {
    console.log("Script is currently disabled.");
    return ContentService.createTextOutput('Script is disabled.');
  }
  try {
    const payload = JSON.parse(e.postData.contents);
    const { issueKey, issueSummary, issueDescription, customDate, companyName, customerId, reporterEmail } = parsePayload(payload);

    if (!customDate) {
      return ContentService.createTextOutput('Custom date field is empty or not in the correct format.');
    }

    const startDate = new Date(customDate);
    const endDate = new Date(startDate);
    endDate.setHours(startDate.getHours() + EVENT_DURATION_HOURS);

    if (isTimeSlotAvailable(CALENDAR_ID, startDate, endDate)) {
      const eventDetails = constructEventDetails(issueKey, issueSummary, issueDescription, companyName, customerId);

      const guests = INFRA_ENGINEERS + (reporterEmail ? "," + reporterEmail : "");

      createCalendarEvent(CALENDAR_ID, eventDetails, startDate, endDate, guests);
      return ContentService.createTextOutput('Calendar event created successfully.');
    } else {
      return ContentService.createTextOutput('Time slot not available.');
    }
  } catch (error) {
    return ContentService.createTextOutput(`Error: ${error.toString()}`);
  }
}

// Function to check if a time slot is available in the calendar
function isTimeSlotAvailable(calendarId, startDate, endDate) {
  const calendar = CalendarApp.getCalendarById(calendarId);
  const events = calendar.getEvents(startDate, endDate);
  return events.length === 0;
}
