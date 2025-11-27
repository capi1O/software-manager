use gtk4::prelude::*;
use gtk4::{Application, ApplicationWindow, Button, TextView, ScrolledWindow};
use std::process::Command;

fn main() {
	let app = Application::builder()
		.application_id("io.github.capi1O.SoftwareManager")
		.build();

	app.connect_activate(build_ui);

	app.run();
}

fn build_ui(app: &Application) {
	let window = ApplicationWindow::builder()
		.application(app)
		.title("Software Manager")
		.default_width(600)
		.default_height(400)
		.build();

	let scrolled = ScrolledWindow::builder()
		.vexpand(true)
		.hexpand(true)
		.build();

	let textview = TextView::builder()
		.editable(false)
		.monospace(true)
		.vexpand(true)
		.hexpand(true)
		.build();

	scrolled.set_child(Some(&textview));

	let button = Button::with_label("List pacman packages");
	let text_buffer = textview.buffer().clone();

	button.connect_clicked(move |_| {
		// Example CLI: list all explicitly installed pacman packages
		let output = Command::new("sh")
			.arg("-c")
			.arg("pacman -Qe")
			.output();

		match output {
			Ok(output) => {
				let result = String::from_utf8_lossy(&output.stdout).to_string();
				text_buffer.set_text(&result);
			}
			Err(e) => {
				text_buffer.set_text(&format!("Error: {}", e));
			}
		}
	});

	let vbox = gtk4::Box::new(gtk4::Orientation::Vertical, 6);
	vbox.append(&button);
	vbox.append(&scrolled);

	window.set_child(Some(&vbox));
	window.show();
}
