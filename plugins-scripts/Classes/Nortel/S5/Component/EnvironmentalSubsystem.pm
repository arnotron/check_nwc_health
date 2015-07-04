package Classes::Nortel::S5::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('S5-CHASSIS-MIB', [
    ['comps', 's5ChasComTable', 'Classes::Nortel::S5::Component::EnvironmentalSubsystem::Comp' ],
  ]);
}

sub check {
  my $self = shift;
  foreach (@{$self->{comps}}) {
    $_->check();
  }
  if (! $self->check_messages()) {
    $self->clear_ok();
    $self->add_ok("environmental hardware working fine");
  }
}


package Classes::Nortel::S5::Component::EnvironmentalSubsystem::Comp;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{s5ChasComShortDescr} = $self->{s5ChasComDescr};
}

sub check {
  my $self = shift;
  my $label = sprintf 'usage', $self->{flat_indices};
  $self->add_info(sprintf 'component %s/%s status is %s (admin %s)',
      $self->{flat_indices}, $self->{s5ChasComShortDescr},
      $self->{s5ChasComOperState}, $self->{s5ChasComAdminState});
  if ($self->{s5ChasComOperState} eq 'removed') {
  } elsif ($self->{s5ChasComAdminState} eq 'disable') {
  } elsif (grep { $self->{s5ChasComOperState} eq $_ }
      (qw(normal resetInProg testing disabled))) {
    $self->add_ok();
  } elsif (grep { $self->{s5ChasComOperState} eq $_ }
      (qw(warning nonFatalErr))) {
    $self->add_ok();
  } elsif (grep { $self->{s5ChasComOperState} eq $_ }
      (qw(fatalErr))) {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }

  $self->add_message($self->check_thresholds(
      metric => $label, value => $self->{s5ChasUtilMemoryUsage}));
}
