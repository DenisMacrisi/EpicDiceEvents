const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const moment = require("moment-timezone");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().gmail.user,
    pass: functions.config().gmail.pass,
  },
});

let flagNotification = false;
// Function used to send scheduled emails to participants
// Every hour checks and sends emails to participans
exports.sendScheduledEmail = functions.pubsub.schedule("every 5 minutes").onRun(async (context) => {
  const db = admin.firestore();

  try {
    const eventsSnapshot = await db.collection("events").get();

    for (const eventDoc of eventsSnapshot.docs) {
      flagNotification = false;

      const event = eventDoc.data();
      const {name, date, isEventActive, isParticipantNotified} = event;
      const extractedDate = moment(date.toDate()).tz("Europe/Bucharest");
      const stringData = extractedDate.toString();
      const displayDate = stringData.substring(0, stringData.indexOf("GMT")).trim();
      const participantsSnapshot = await db.collection("events").doc(eventDoc.id).collection("participantsList").get();

      if (participantsSnapshot.empty) {
        continue;
      }
      for (const participantDoc of participantsSnapshot.docs) {
        const participantId = participantDoc.id;

        const userDoc = await db.collection("users").doc(participantId).get();
        if (!userDoc.exists) {
          continue;
        }

        const currentDate = moment().tz("Europe/Bucharest");
        const diffence = extractedDate - currentDate;
        const hours = diffence/(1000*60*60);

        if (hours >= 23 && hours <= 24 && isEventActive == true) {
          console.log(`extractedDate: ${extractedDate}`);
          console.log(`currentDate: ${currentDate}`);
          console.log(`diff: ${diffence}`);
          console.log(`stringData: ${stringData}`);
          console.log(`displayDate: ${displayDate}`);
          const userData = userDoc.data();
          console.log(`User ${participantId}`);
          console.log(`Email ${userData.email}`);
          const mailOptions = {
            from: functions.config().gmail.user,
            to: userData.email,
            subject: `Reminder pentru Evenimentul: ${name}`,
            text: `Salutare ${userData.username},\n\nEvenimentul tau ${name} programat la data ${displayDate} va începe curând.\n\\Toate cele bune,\nEpicDiceEvents`,
            html: `<p>Salutare ${userData.username},</p>
                   <p>Evenimentul tau <strong>${name}</strong> 
                   programat la data <strong>${displayDate}</strong>
                   va începe curând.</p>
                   <p>Toate cele bune,<br>EpicDiceEvents</p>`,
          };
          transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
              console.log(error);
            } else {
              console.log(`Email sent: ${info.response}`);
            }
          });
        }
        if (isEventActive == false && isParticipantNotified == false) {
          flagNotification = true;

          const userData = userDoc.data();
          const mailOptions = {
            from: functions.config().gmail.user,
            to: userData.email,
            subject: `Eveniment Anulat: ${name}`,
            text: `Salutare ${userData.username},\n\nEvenimentul tau ${name} programat la data ${displayDate} a fost anulat de către organizator.\n\\Toate cele bune,\nEpicDiceEvents`,
            html: `<p>Salutare ${userData.username},</p>
                   <p>Evenimentul tau <strong>${name}</strong> 
                   programat la data <strong>${displayDate}</strong>
                   a fost anulat de către organizator.</p>
                   <p>Toate cele bune,<br>EpicDiceEvents</p>`,
          };
          transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
              console.log(error);
            } else {
              console.log(`Email sent: ${info.response}`);
            }
          });
        }
        if (flagNotification == true) {
          await db.collection("events").doc(eventDoc.id).update({
            isParticipantNotified: true,
          });
        }
      }
    }
  } catch (error) {
    console.error("Error fetching events:", error);
  }
});

const {OpenAI} = require("openai");

const openai = new OpenAI({
  apiKey: functions.config().openai.api.key,
});


exports.getGameSuggestion = functions.pubsub.schedule("every 1200 minutes").onRun(async (context) => {
  try {
    // Obținem titlul jocului
    const titleResponse = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: "Genereaza titlul unui joc de masă ce l-ai sugera de jucat pentru o seară de jocuri(ofera numele orginal al jocului, in limba in care a fost publicat, nu incerca sa traduci). Nu adăugați descrierea, doar titlul.(Încearcă să fie un titlu nici prea cunoscut, dar nici unul prea extravagant)",
        },
      ],
    });

    const title = titleResponse.choices[0].message.content.trim();
    console.log("Titlu obținut:", title);

    // Dacă titlul este valid, obținem descrierea
    if (title) {
      const descriptionResponse = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: `Generează o descriere scurtă și artistică in limba română (o fraza) ca să prezinți cât mai atractiv jocul: "${title}".`,
          },
        ],
      });
      let description = descriptionResponse.choices[0].message.content.trim();
      console.log("Descriere obținută:", description);

      // Dacă descrierea este goală, încercăm din nou să o generăm
      if (!description) {
        console.log("Descrierea este goală, încercăm din nou...");
        const retryDescriptionResponse = await openai.chat.completions.create({
          model: "gpt-4",
          messages: [
            {
              role: "system",
              content: `Oferă o descriere scurtă și artistică (o fraza, maxim doua) a jocului de masă "${title}".`,
            },
          ],
        });
        description = retryDescriptionResponse.choices[0].message.content.trim();
      }

      // Verificăm dacă titlul și descrierea sunt valide
      if (title && description) {
        // Actualizăm documentul în Firestore
        const docRef = admin.firestore().collection("suggestion").doc("q4MLFWfMXNAj1E1LmFgb");

        await docRef.update({
          name: title,
          description: description,
        });

        console.log("Sugestie generată și documentul actualizat în Firestore!");
      } else {
        console.error("Titlul sau descrierea sunt invalide.");
      }
    } else {
      console.error("Nu am obținut un titlu valid.");
    }
  } catch (error) {
    console.error("Eroare la generarea sugestiei:", error);
  }
});
