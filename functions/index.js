const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure your email transporter
const transporter = nodemailer.createTransport({
    service: "Gmail",
    auth: {
        user: "ajoud7101@gmail.com",
        pass: "0555598476",
    },
});

// Trigger function when a file is uploaded to /violation_images
exports.sendEmailOnImageUpload = functions.storage
    .object()
    .onFinalize(async (object) => {
        // Check if the file is in the "violation_images" folder
        const filePath = object.name; // Full path of the file
        if (!filePath.startsWith("violation_images/")) {
            console.log("File is not in violation_images folder, ignoring.");
            return null;
        }

        const fileName = filePath.split("/").pop(); // Get the file name
        const bucketName = object.bucket; // Storage bucket name
        const fileUrl = "https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(filePath)}?alt=media";

        // Compose the email
        const mailOptions = {
            from: "ajoud7101@gmail.com",
            to: "alharbi55555b@gmail.com",
            subject: `New Image Uploaded: ${fileName}`,
            text: "A new image has been uploaded to the violation_images folder:\n\nFile URL: ${fileUrl}",
        };

        // Send the email
        try {
            await transporter.sendMail(mailOptions);
            console.log("Email sent for file: ${fileName}");
        } catch (error) {
            console.error("Error sending email:", error);
        }

        return null;
    });
