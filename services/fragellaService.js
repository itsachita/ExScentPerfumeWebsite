const FRAGELLA_API_BASE = 'https://api.fragella.com/api/v1';

/**
 * Service to handle interactions with the Fragella API.
 */
class FragellaService {
    constructor(apiKey) {
        this.apiKey = apiKey;
    }

    /**
     * Search for a fragrance by name.
     * @param {string} name - The name of the perfume.
     * @returns {Promise<Object|null>} - The first fragrance result or null.
     */
    async searchFragrance(name) {
        if (!this.apiKey || this.apiKey === 'YOUR_API_KEY_HERE') {
            console.warn('Fragella API Key is missing or invalid.');
            return null;
        }

        try {
            const response = await fetch(`${FRAGELLA_API_BASE}/fragrances?search=${encodeURIComponent(name)}&limit=1`, {
                headers: {
                    'x-api-key': this.apiKey
                }
            });

            if (!response.ok) {
                const errorData = await response.json();
                console.error('Fragella API Error:', errorData);
                return null;
            }

            const data = await response.json();
            return data.length > 0 ? data[0] : null;
        } catch (error) {
            console.error('Error calling Fragella API:', error);
            return null;
        }
    }
}

module.exports = FragellaService;
