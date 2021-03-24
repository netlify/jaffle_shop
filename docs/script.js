window.identityLoaded = function() {
    "netlifyIdentity" in window && (window.netlifyIdentity.on("init", n => {
        window.netlifyIdentity.store.loadSettings()
    }), window.netlifyIdentity.on("open", n => {
        window.netlifyIdentity.store.loadSettings(), window.netlifyIdentity.store.settings && (window.netlifyIdentity.store.settings.disable_signup = !0)
    }), window.netlifyIdentity.on("login", n => {
        if ("URL" in window && document.getElementById("netlify-identity-refresh-page")) {
            const n = new URL(document.location.href);
            "login" !== n.searchParams.get("refresh") && window.netlifyIdentity.refresh().then(t => {
                n.searchParams.set("refresh", "login"), document.location.href = n.toString()
            }).catch(n => {
                console.log("Identity Error: Unable to get new valid token. logging out user", n),
                    function() {
                        if ("netlifyIdentity" in window) {
                            const n = window.netlifyIdentity.store;
                            n && (n.user = null, n.modal.page = "login", n.saving = !1)
                        }
                    }(), window.netlifyIdentity.open()
            })
        }
    }), window.netlifyIdentity.on("logout", () => {
        if ("URL" in window) {
            const n = new URL(document.location.href);
            "logout" !== n.searchParams.get("refresh") && (n.searchParams.set("refresh", "logout"), document.location.href = n.toString())
        }
    }), window.netlifyIdentity.on("error", n => {
        console.error("Netlify Identity Error", n)
    }), netlifyIdentity.on("init", n => console.log("init", n)), netlifyIdentity.on("login", n => console.log("login", n)), netlifyIdentity.on("logout", () => console.log("Logged out")), netlifyIdentity.on("error", n => console.error("Error", n)))
};
