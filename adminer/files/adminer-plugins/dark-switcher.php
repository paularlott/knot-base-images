<?php

/** Allow switching light and dark mode.
* Vendored from Adminer's plugins/dark-switcher.php (v6.0.1, Apache-2.0 / GPL-2.0,
* © Jakub Vrana) and adapted: instead of enabling Adminer's dark.css (which the
* adminer.css theme overrides anyway), it sets html[data-theme] which the theme's
* dark palette responds to. Defaults to dark, remembers the user's choice in
* localStorage, and applies it from <head> so the page never flashes light.
* @link https://www.adminer.org/plugins/#use
* @license https://www.apache.org/licenses/LICENSE-2.0 Apache License 2.0
* @license https://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
*/
class AdminerDarkSwitcher extends Adminer\Plugin {

	function head($dark = null) {
		?>
<script <?php echo Adminer\nonce(); ?>>
let adminerDark;

function adminerDarkSwitch() {
	adminerDark = !adminerDark;
	adminerDarkSet(true);
}

function adminerDarkSet(persist) {
	document.documentElement.dataset.theme = (adminerDark ? 'dark' : 'light'); // the adminer.css theme carries both palettes
	qs('meta[name="color-scheme"]').content = (adminerDark ? 'dark' : 'light');
	if (persist) {
		try { localStorage.setItem('adminer_theme', adminerDark ? 'dark' : 'light'); } catch (e) {}
	}
	const button = document.getElementById('theme-toggle');
	if (button) {
		button.textContent = (adminerDark ? '☀' : '☾');
		button.title = (adminerDark ? 'Switch to light mode' : 'Switch to dark mode');
	}
}

let savedTheme = null;
try { savedTheme = localStorage.getItem('adminer_theme'); } catch (e) {}
adminerDark = (savedTheme == 'light' || savedTheme == 'dark' ? savedTheme == 'dark' : true);
adminerDarkSet(false);
</script>
<?php
	}

	function navigation($missing) {
		// the click handler must be bound from a nonce'd script: Adminer's CSP
		// blocks inline onclick attributes, and data-onclick delegation is not
		// reliable for elements injected by plugins. When logged in, the toggle
		// is moved into the logout block (top-right); on the login page it keeps
		// its fixed bottom-right fallback position from adminer.css.
		echo "<button type='button' id='theme-toggle'>☾</button>"
			. Adminer\script("
				document.addEventListener('DOMContentLoaded', function () {
					const adminerThemeToggle = document.getElementById('theme-toggle');
					const adminerLogout = document.querySelector('p.logout'); // rendered after this script
					if (adminerThemeToggle && adminerLogout) {
						adminerLogout.insertBefore(adminerThemeToggle, adminerLogout.firstChild);
					}
					if (adminerThemeToggle) {
						adminerThemeToggle.onclick = adminerDarkSwitch;
					}
					adminerDarkSet(false);
				});
			") . "\n"
		;
	}

	protected $translations = array();
}
