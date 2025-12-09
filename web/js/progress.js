// ========================================
// PROGRESS MANAGEMENT SYSTEM
// ========================================

class ProgressManager {
    constructor() {
        this.progress = this.loadProgress();
        this.apiBaseUrl = 'http://localhost:3000';
        this.tykBaseUrl = 'http://localhost:8080';
        this.kongBaseUrl = 'http://localhost:8000';
    }

    // Load progress from localStorage
    loadProgress() {
        const saved = localStorage.getItem('api-gateway-progress');
        if (saved) {
            try {
                const progress = JSON.parse(saved);

                // MIGRACIÓN: Convertir ejercicio 8 a ejercicio 7
                ['tyk', 'kong'].forEach(gateway => {
                    if (progress[gateway] && progress[gateway][8]) {
                        // Si existe el ejercicio 8, moverlo al 7
                        console.log(`Migrando ejercicio 8 a 7 para ${gateway}`);
                        progress[gateway][7] = progress[gateway][8];
                        delete progress[gateway][8];
                    }
                    // Asegurar que el ejercicio 7 existe
                    if (progress[gateway] && !progress[gateway][7]) {
                        progress[gateway][7] = { completed: false, unlocked: false };
                    }
                });

                // Guardar la migración
                localStorage.setItem('api-gateway-progress', JSON.stringify(progress));

                return progress;
            } catch (e) {
                console.error('Error loading progress:', e);
            }
        }

        // Default progress structure
        return {
            tyk: {
                1: { completed: false, unlocked: true },
                2: { completed: false, unlocked: false },
                3: { completed: false, unlocked: false },
                4: { completed: false, unlocked: false },
                5: { completed: false, unlocked: false },
                6: { completed: false, unlocked: false },
                7: { completed: false, unlocked: false }
            },
            kong: {
                1: { completed: false, unlocked: true },
                2: { completed: false, unlocked: false },
                3: { completed: false, unlocked: false },
                4: { completed: false, unlocked: false },
                5: { completed: false, unlocked: false },
                6: { completed: false, unlocked: false },
                7: { completed: false, unlocked: false }
            },
            stats: {
                totalRequests: 0,
                successRequests: 0,
                totalTime: 0
            }
        };
    }

    // Save progress to localStorage
    saveProgress() {
        localStorage.setItem('api-gateway-progress', JSON.stringify(this.progress));
    }

    // Mark exercise as completed
    completeExercise(gateway, exerciseNum) {
        if (this.progress[gateway] && this.progress[gateway][exerciseNum]) {
            this.progress[gateway][exerciseNum].completed = true;

            // Unlock next exercise
            const nextExercise = exerciseNum + 1;
            if (this.progress[gateway][nextExercise]) {
                this.progress[gateway][nextExercise].unlocked = true;
            }

            this.saveProgress();
            return true;
        }
        return false;
    }

    // Check if exercise is unlocked
    isUnlocked(gateway, exerciseNum) {
        return this.progress[gateway]?.[exerciseNum]?.unlocked || false;
    }

    // Check if exercise is completed
    isCompleted(gateway, exerciseNum) {
        return this.progress[gateway]?.[exerciseNum]?.completed || false;
    }

    // Get total progress percentage
    getTotalProgress() {
        let total = 0;
        let completed = 0;

        ['tyk', 'kong'].forEach(gateway => {
            Object.values(this.progress[gateway]).forEach(exercise => {
                total++;
                if (exercise.completed) completed++;
            });
        });

        return total > 0 ? Math.round((completed / total) * 100) : 0;
    }

    // Get completed count
    getCompletedCount() {
        let completed = 0;
        let total = 0;

        ['tyk', 'kong'].forEach(gateway => {
            Object.values(this.progress[gateway]).forEach(exercise => {
                total++;
                if (exercise.completed) completed++;
            });
        });

        return { completed, total };
    }

    // Get gateway specific progress
    getGatewayProgress(gateway) {
        let completed = 0;
        Object.values(this.progress[gateway]).forEach(exercise => {
            if (exercise.completed) completed++;
        });
        return completed;
    }

    // Update stats
    updateStats(success, time) {
        this.progress.stats.totalRequests++;
        if (success) {
            this.progress.stats.successRequests++;
        }
        this.progress.stats.totalTime += time;
        this.saveProgress();
    }

    // Get average time
    getAverageTime() {
        if (this.progress.stats.totalRequests === 0) return 0;
        return Math.round(this.progress.stats.totalTime / this.progress.stats.totalRequests);
    }

    // Reset progress
    resetProgress() {
        localStorage.removeItem('api-gateway-progress');
        this.progress = this.loadProgress();
    }

    // Check exercise completion by checking if config exists
    async checkExerciseCompletion(gateway, exerciseNum) {
        try {
            let endpoint;

            // Different endpoints for Tyk and Kong based on exercise
            if (gateway === 'tyk') {
                endpoint = this.getTykEndpoint(exerciseNum);
            } else {
                endpoint = this.getKongEndpoint(exerciseNum);
            }

            const headers = this.getHeaders(gateway, exerciseNum);

            // Retry logic for better reliability
            let maxRetries = 3;
            let retryDelay = 500;

            for (let attempt = 0; attempt < maxRetries; attempt++) {
                try {
                    console.log(`🔍 Verificando ${gateway}-${exerciseNum} (intento ${attempt + 1}/${maxRetries})`);
                    console.log(`   Endpoint: ${endpoint}`);
                    console.log(`   Headers:`, headers);

                    const response = await fetch(endpoint, {
                        method: 'GET',
                        headers: headers,
                        mode: 'cors'
                    });

                    console.log(`   Respuesta: ${response.status} ${response.statusText}`);
                    console.log(`   Response.ok: ${response.ok}`);

                    // Success codes:
                    // - 2xx (response.ok): Success
                    // - 401: Auth is configured (expected for Exercise 2)
                    // - 429: Rate limit working (expected for Exercise 3)
                    if (response.ok || response.status === 401 || response.status === 429) {
                        console.log(`✅ Ejercicio ${gateway}-${exerciseNum} verificado correctamente!`);
                        return true;
                    }

                    // If we get 404 or 500+, the exercise is not configured
                    if (response.status === 404 || response.status >= 500) {
                        console.log(`❌ Ejercicio no configurado (${response.status})`);
                        if (attempt < maxRetries - 1) {
                            console.log(`   ⏳ Reintentando en ${retryDelay}ms...`);
                            await new Promise(resolve => setTimeout(resolve, retryDelay));
                            retryDelay *= 2;
                            continue;
                        }
                        return false;
                    }

                    // Other unexpected status codes
                    console.log(`⚠️ Código inesperado: ${response.status}`);
                    if (attempt < maxRetries - 1) {
                        await new Promise(resolve => setTimeout(resolve, retryDelay));
                        retryDelay *= 2;
                        continue;
                    }

                } catch (error) {
                    console.log(`   ❌ Error en request:`, error);
                    console.log(`   Tipo de error: ${error.name}`);
                    console.log(`   Mensaje: ${error.message}`);

                    // Check if it's a CORS or network error
                    if (error.name === 'TypeError') {
                        console.log(`   🚨 Posible error de CORS o red. Verifica que los servicios estén corriendo.`);
                    }

                    if (attempt < maxRetries - 1) {
                        console.log(`   ⏳ Reintentando en ${retryDelay}ms...`);
                        await new Promise(resolve => setTimeout(resolve, retryDelay));
                        retryDelay *= 2; // exponential backoff
                        continue;
                    }
                }
            }

            return false;
        } catch (error) {
            console.log('Exercise not yet configured:', error);
            return false;
        }
    }

    // Get Tyk endpoint for exercise
    getTykEndpoint(exerciseNum) {
        const endpoints = {
            1: `${this.tykBaseUrl}/calc/suma?a=15&b=25`,
            2: `${this.tykBaseUrl}/calc/divide?a=100&b=5`,
            3: `${this.tykBaseUrl}/calc/multiplica?a=7&b=8`,
            4: `${this.tykBaseUrl}/calc/suma?a=15&b=25`,
            5: `${this.tykBaseUrl}/calc/resta?a=100&b=35`,
            6: `${this.tykBaseUrl}/versioned/raiz?n=25`,  // API Versionada
            7: `${this.tykBaseUrl}/logged/resta?a=100&b=35`  // Logging
        };
        return endpoints[exerciseNum] || `${this.tykBaseUrl}/calc/suma?a=15&b=25`;
    }

    // Get Kong endpoint for exercise
    getKongEndpoint(exerciseNum) {
        const endpoints = {
            1: `${this.kongBaseUrl}/calc/suma?a=15&b=25`,
            2: `${this.kongBaseUrl}/calc/divide?a=100&b=5`,
            3: `${this.kongBaseUrl}/calc/multiplica?a=7&b=8`,
            4: `${this.kongBaseUrl}/calc/suma?a=15&b=25`,
            5: `${this.kongBaseUrl}/calc/resta?a=100&b=35`,
            6: `${this.kongBaseUrl}/v2/direct/raiz?n=25`,  // API Versionada
            7: `${this.kongBaseUrl}/logged/resta?a=100&b=35`  // File Log
        };
        return endpoints[exerciseNum] || `${this.kongBaseUrl}/calc/suma?a=15&b=25`;
    }

    // Get headers for request
    getHeaders(gateway, exerciseNum) {
        const headers = {
            'Content-Type': 'application/json'
        };

        // Add auth headers for auth exercises
        if (exerciseNum === 2) {
            if (gateway === 'tyk') {
                headers['Authorization'] = 'test-key-123';
            } else {
                headers['apikey'] = 'calc-secret-key-12345';
            }
        }

        // Add versioning header for Tyk exercise 6
        if (exerciseNum === 6 && gateway === 'tyk') {
            headers['X-API-Version'] = 'v2';
        }

        return headers;
    }

    // Auto-check all exercises
    async autoCheckProgress() {
        console.log('Auto-checking exercise progress...');

        for (const gateway of ['tyk', 'kong']) {
            for (let i = 1; i <= 9; i++) {
                if (!this.isCompleted(gateway, i) && this.isUnlocked(gateway, i)) {
                    const isConfigured = await this.checkExerciseCompletion(gateway, i);
                    if (isConfigured && !this.isCompleted(gateway, i)) {
                        console.log(`Exercise ${gateway}-${i} auto-completed!`);
                        this.completeExercise(gateway, i);
                    }
                }
            }
        }
    }
}

// Create global instance
window.progressManager = new ProgressManager();

// Auto-check progress every 10 seconds - DISABLED to prevent auto-completion
// Los ejercicios solo se marcarán como completados cuando el usuario haga clic en "Verificar Ahora"
// setInterval(() => {
//     window.progressManager.autoCheckProgress();
// }, 10000);
