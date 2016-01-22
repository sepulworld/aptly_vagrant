#Configure Aptly and API 
class aptly_vagrant {

  class { 'aptly': config => {
    rootDir                     => "/vagrant_data/.aptly",
    architectures               => [],
    dependencyFollowSuggests    => false,
    dependencyFollowRecommends  => false,
    dependencyFollowAllVariants => false,
    dependencyFollowSource      => false,
    gpgDisableSign              => false,
    gpgDisableVerify            => false,
    downloadSourcePackages      => false,
    ppaDistributorID            => "ubuntu",
    ppaCodename                 => "",
    },
  }

  aptly::repo { 'stable-repo': 
  }

  aptly::repo { 'testing-repo': 
  }
  
  aptly::repo { 'rocksoftware22': 
  }

  file { "/vagrant_data/.aptly":
    ensure => directory,
    owner  => www-data,
    group  => www-data,
    before => Package['aptly'],
  }

  file { "/vagrant_data/.aptly/public":
    ensure  => directory,
    owner   => www-data,
    group   => www-data,
    require => File["/vagrant_data/.aptly"],
  }

  nginx::resource::vhost { 'aptly.localhost':
    www_root  => '/vagrant_data/.aptly/public',
    autoindex => 'on',
  }

  exec { "add_debs_to_rocksoftware_repo":
    command => "/usr/bin/aptly repo add rocksoftware22 /vagrant/debs/testing/",
    require => Aptly::Repo['rocksoftware22'],
  }
  
  exec { "add_debs_to_stable_repo":
    command => "/usr/bin/aptly repo add stable-repo /vagrant/debs/stable/",
    require => Aptly::Repo['stable-repo'],
  }
  
  exec { "add_debs_to_testing_repo":
    command => "/usr/bin/aptly repo add testing-repo /vagrant/debs/stable/",
    require => Aptly::Repo['testing-repo'],
  }

  aptly::snapshot { 'rocksoftware22_snap': 
    repo   => 'rocksoftware22', 
  }

  package { "aptly_cli":
    provider => gem,
    ensure   => latest,
  }
  
  class { 'aptly::api': 
    listen => ':8082', 
    log    => 'log',
    require => Class['Aptly']
  }

}
