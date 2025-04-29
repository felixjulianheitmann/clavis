Name:           clavis
Version:        %{clavis_version}
Release:        1%{?dist}
Summary:        An alternative client application to your Gamevault instance

License:        LICENSE
URL:            https://github.com/felixjulianheitmann/clavis
Source0:        %{name}-%{clavis_version}.tar.gz
BuildArch:      %{clavis_arch}

Requires:       libsecret jsoncpp 

%description
clavis is a client application for Gamevault. It's not affiliated with Phalcode and merely uses the Gamevault backend API to provide a solid game management application

%prep


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}/%{name}
mkdir -p %{buildroot}%{_datadir}/applications
cp -r %{_sourcedir}/app/*    %{buildroot}%{_bindir}/%{name}
cp %{_sourcedir}/%{name}.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop


%clean
rm -rf %{buildroot}

%files
%{_bindir}/%{name}/*
%{_datadir}/applications/%{name}.desktop

%changelog
* Fri Apr 25 2025 Felix Bruns <felix@bruns.hamburg>
- 
