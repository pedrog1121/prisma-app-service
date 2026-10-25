{{flutter_js}}
{{flutter_build_config}}

// Monta la app dentro del marco del celular en lugar de ocupar toda la página.
_flutter.loader.load({
  config: { canvasKitBaseUrl: 'canvaskit/' },
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.getElementById('app'),
    });
    await appRunner.runApp();
    const loading = document.getElementById('loading');
    if (loading) {
      loading.style.opacity = '0';
      setTimeout(() => loading.remove(), 300);
    }
  },
});
