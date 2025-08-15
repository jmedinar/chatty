# chatty.spec
# Spec file for building the chatty RPM package.

Name:           chatty
Version:        1.7
Release:        0%{?dist}
Summary:        An interactive Linux learning framework to build exercises in the CLI.
License:        MIT
URL:            https://github.com/jmedinar/chatty
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  python3-pyyaml

%description
ChaTTY is an interactive learning framework for Linux, designed to guide
students through terminal exercises. It reads tasks from YAML files,
provides descriptions, actions to perform, and allows for verification
of completed tasks. It supports saving and reloading progress.

%prep

%setup -q

%build
chmod +x chatty

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/%{name}.d
install -m 0755 chatty %{buildroot}/usr/bin/%{name}
install -m 0644 tasks/*.yml %{buildroot}/etc/%{name}.d/

%files
%defattr(-,root,root,-)
/usr/bin/%{name}
/etc/%{name}.d/
# %doc README.md # If you have a README.md, include it here
# %license LICENSE # If you have a LICENSE file, include it here

%changelog
* Tue Jul 30 2024 Juan Medina jmedina@collin.edu - 1.0.0-1
- Initial RPM package creation.
- Changed YAML module location to /etc/chatty.d.
- Updated script to load modules by name from /etc/chatty.d.
- Added the functionality of --list