// Musiverse Landing Page Interactive Logic

// ==========================================================================
// Screen Data Definitions
// ==========================================================================
const screenData = {
    splash: {
        title: "Splash Screen",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.29 PM.jpeg",
        icon: "music-2",
        tags: ["Flutter UI", "Branding"],
        description: "The gateway to Musiverse. This view welcomes users with our custom glowing neon cyan and red logo set against an immersive violet and navy blue background gradient, establishing the app's dark-mode signature style."
    },
    login: {
        title: "Secure Login",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.29 PM (1).jpeg",
        icon: "lock",
        tags: ["Authentication", "Spring Security"],
        description: "A clean, modern credential login page. To guarantee a highly personalized experience with persistent stats and custom upload databases, we deprecated Guest Mode, ensuring every active user is securely authenticated."
    },
    home: {
        title: "Home Dashboard",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.29 PM (2).jpeg",
        icon: "home",
        tags: ["Feeds", "Discovery"],
        description: "The central music hub. Greets users with context-aware messages ('Good Evening') and provides a powerful search bar, a featured scrolling banner, and a quick list of top tracks, complete with instant 'like' toggles."
    },
    categories: {
        title: "Browse Categories",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.30 PM.jpeg",
        icon: "grid",
        tags: ["Search", "Genres"],
        description: "A visually striking category finder. Users can explore music tailored to their exact mood or language via grid cards styled in vibrant HSL gradients, covering English, Hindi, Punjabi, Korean, Pop, Romantic, and more."
    },
    songlist: {
        title: "Category Playlist",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.30 PM (1) copy.jpeg",
        icon: "list-music",
        tags: ["Playlists", "Favorites"],
        description: "A dedicated song list for the selected category. Displays song details, artist names, albums, release years, and a list-wide favorite toggle, complete with clean album art containers and sleek neon borders."
    },
    library: {
        title: "Your Library",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.30 PM (2).jpeg",
        icon: "library",
        tags: ["User Data", "Playback"],
        description: "A unified view of user activity. Offers quick tabs for 'Liked Songs' and 'Recently Played' histories, paired with dual-button controls to immediately 'Play All' or 'Shuffle' the selected compilation."
    },
    manage: {
        title: "Manage Songs",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.31 PM.jpeg",
        icon: "upload-cloud",
        tags: ["Creator Tools", "CRUD"],
        description: "The music upload dashboard. Creators can hit the '+' action button to upload new tracks. The dashboard lists user-contributed songs, complete with inline edit (pencil) and hide (trash) buttons for simple track management."
    },
    profile: {
        title: "User Profile",
        image: "../frontend/assets/images/WhatsApp Image 2026-07-02 at 11.05.31 PM (1).jpeg",
        icon: "user",
        tags: ["Preferences", "Privacy"],
        description: "User dashboard displaying stats (counts of liked and played songs), quick profile detail edits, notification settings, and a dedicated Privacy page where users can manage their hidden tracks and instantly 'unhide' them."
    }
};

// ==========================================================================
// Interactive Showcase Handler
// ==========================================================================
document.addEventListener("DOMContentLoaded", () => {
    const tabs = document.querySelectorAll(".showcase-tab");
    const mockupImg = document.getElementById("mockup-img");
    const expIcon = document.getElementById("explanation-icon");
    const expTitle = document.getElementById("explanation-title");
    const expText = document.getElementById("explanation-text");
    const metaContainer = document.querySelector(".screen-metadata");
    const autoplayContainer = document.querySelector(".showcase-autoplay-indicator");
    
    let activeKey = "splash";
    let autoplayTimer = null;
    const autoplayInterval = 5000; // 5 seconds per slide
    let isPaused = false;

    // Ordered keys for autoplay sequence
    const keys = Object.keys(screenData);

    // Switch screen UI with transition effects
    function switchScreen(key) {
        if (!screenData[key]) return;
        activeKey = key;
        const data = screenData[key];

        // 1. Set fade-out class on image
        mockupImg.classList.add("img-fade-out");

        // 2. Update active tab classes
        tabs.forEach(tab => {
            if (tab.dataset.screen === key) {
                tab.classList.add("active");
                // Scroll tab into view if container is scrolling horizontally on mobile
                tab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
            } else {
                tab.classList.remove("active");
            }
        });

        // 3. Change image src and text fields after fade duration
        setTimeout(() => {
            mockupImg.src = data.image;
            mockupImg.alt = data.title;
            expTitle.textContent = data.title;
            expText.textContent = data.description;
            
            // Update icon
            expIcon.setAttribute("data-lucide", data.icon);
            
            // Re-render meta tags
            metaContainer.innerHTML = "";
            data.tags.forEach(tag => {
                const span = document.createElement("span");
                span.className = "meta-tag";
                span.textContent = tag;
                metaContainer.appendChild(span);
            });
            
            // Re-generate Lucide icons for the updated container
            lucide.createIcons();
            
            // Remove fade-out class
            mockupImg.classList.remove("img-fade-out");
        }, 200);

        // Reset progress bar animation
        resetProgressAnimation();
    }

    // Progress bar handler for autoplay visual indicator
    function resetProgressAnimation() {
        autoplayContainer.classList.remove("autoplay-active");
        // Force reflow/repaint to restart CSS transition
        void autoplayContainer.offsetWidth; 
        if (!isPaused) {
            autoplayContainer.classList.add("autoplay-active");
        }
    }

    // Go to next slide in autoplay cycle
    function nextSlide() {
        if (isPaused) return;
        const currentIndex = keys.indexOf(activeKey);
        const nextIndex = (currentIndex + 1) % keys.length;
        switchScreen(keys[nextIndex]);
    }

    // Start/Restart Autoplay Timer
    function startAutoplay() {
        stopAutoplay();
        autoplayTimer = setInterval(nextSlide, autoplayInterval);
        resetProgressAnimation();
    }

    // Stop/Clear Autoplay Timer
    function stopAutoplay() {
        if (autoplayTimer) {
            clearInterval(autoplayTimer);
            autoplayTimer = null;
        }
        autoplayContainer.classList.remove("autoplay-active");
    }

    // Click events for tabs
    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            const screenKey = tab.dataset.screen;
            switchScreen(screenKey);
            // Restart autoplay when user explicitly selects a slide
            startAutoplay();
        });
    });

    // Pause autoplay on hover over showcase elements
    const hoverContainers = [
        document.querySelector(".showcase-nav"),
        document.querySelector(".device-column"),
        document.querySelector(".explanation-column")
    ];

    hoverContainers.forEach(container => {
        if (container) {
            container.addEventListener("mouseenter", () => {
                isPaused = true;
                stopAutoplay();
            });
            container.addEventListener("mouseleave", () => {
                isPaused = false;
                startAutoplay();
            });
        }
    });

    // Initialize Autoplay
    startAutoplay();

    // ==========================================================================
    // Active Link Scroll Highlighter
    // ==========================================================================
    const sections = document.querySelectorAll("section");
    const navLinks = document.querySelectorAll(".nav-links a");

    window.addEventListener("scroll", () => {
        let current = "";
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            // Check if scroll is past section start minus offset
            if (pageYOffset >= (sectionTop - 120)) {
                current = section.getAttribute("id");
            }
        });

        navLinks.forEach(link => {
            link.classList.remove("active-link");
            if (link.getAttribute("href") === `#${current}`) {
                link.classList.add("active-link");
            }
        });
    });
});
