// Search-Replace the following:
// Netlify -> Your Org Name
// netlify -> your org name
// @netlify.com -> @yourdomainname.com
const jws = require("jws");

exports.handler = async function(event) {
	if ("WEBHOOK_SECRET" in process.env) {
		const signature = event.headers["x-webhook-signature"];
		if (!jws.verify(signature, "HS256", process.env.WEBHOOK_SECRET)) {
			console.log("Webhook signature invalid:", signature);
			return {
				statusCode: 401
			};
		}
	}

	const {
		user: { email, app_metadata }
	} = JSON.parse(event.body);
	// User is part of Netlify and already has role
	const found = app_metadata.roles && app_metadata.roles.find(r => r == "netlify") !== undefined;

	if (found) {
		return {
			statusCode: 200
		};
	}

	if (email && email.endsWith("@netlify.com")) {
		console.log("User is part of Netlify without role. assigning...");
		const roles = (app_metadata && app_metadata.roles) || [];
		const metadata = {
			...app_metadata,
			roles: [...roles, "netlify"]
		};
		return {
			statusCode: 200,
			body: JSON.stringify({ app_metadata: metadata })
		};
	}

	console.log("User is not part of Netlify.");
	return {
		statusCode: 401
	};
};
