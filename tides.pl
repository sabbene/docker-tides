#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
#use WWW::Curl::Easy;
use Mojo::UserAgent;
use Data::Dump qw(pp);

my $json = JSON->new->allow_nonref;

my %forcast_locations = (
    santa_cruz => {
        name              => 'Santa Cruz',
        base_url          => 'https://api.weather.gov/points/36.9561,-122.012',
        tide_forcast_url  => 'https://tidesandcurrents.noaa.gov/api/datagetter?station=9413745&range=24&product=predictions&datum=mllw&units=english&time_zone=lst_ldt&format=json&interval=hilo',
        alerts_url        => 'https://api.weather.gov//alerts?active=1&point=36.9561,-122.012',
        noaa_url          => 'http://marine.weather.gov/MapClick.php?lat=36.9561&lon=-122.012',
    },
    elkhorn_slough => {
        name              => 'Elkhorn Slough',
        base_url          => 'https://api.weather.gov/points/36.8,-121.79',
        tide_forcast_url  => 'https://tidesandcurrents.noaa.gov/api/datagetter?station=9413623&range=24&product=predictions&datum=mllw&units=english&time_zone=lst_ldt&format=json&interval=hilo',
        alerts_url        => 'https://api.weather.gov//alerts?active=1&point=36.80,-121.79',
        noaa_url          => 'http://marine.weather.gov/MapClick.php?lat=36.80&lon=-121.79',
    },
    panther_beach => {
        name             => 'Panther Beach',
        base_url         => 'https://api.weather.gov/points/36.9928,-122.1701',
        tide_forcast_url => 'https://tidesandcurrents.noaa.gov/api/datagetter?station=9413878&range=24&product=predictions&datum=mllw&units=english&time_zone=lst_ldt&format=json&interval=hilo',
        alerts_url       => 'https://api.weather.gov//alerts?active=1&point=36.9928,-122.1701',
        noaa_url         => 'http://marine.weather.gov/MapClick.php?lat=36.9928&lon=-122.1701'
    },
    dumbarton_bridge => {
        name             => 'Dumbarton Bridge',
        base_url         => 'https://api.weather.gov/points/37.5055,-122.1181',
        tide_forcast_url => 'https://tidesandcurrents.noaa.gov/api/datagetter?station=9414509&range=24&product=predictions&datum=mllw&units=english&time_zone=lst_ldt&format=json&interval=hilo',
        alerts_url       => 'https://api.weather.gov//alerts?active=1&point=37.5055,-122.1181',
        noaa_url         => 'http://marine.weather.gov/MapClick.php?lat=37.5055&lon=-122.1181'
    },
    san_gregorio => {
        name             => 'San Gregorio',
        base_url         => 'https://api.weather.gov/points/37.3231,-122.4008',
        tide_forcast_url => 'https://tidesandcurrents.noaa.gov/api/datagetter?station=9413450&range=24&product=predictions&datum=mllw&units=english&time_zone=lst_ldt&format=json&interval=hilo',
        alerts_url       => 'https://api.weather.gov//alerts?active=1&point=37.3231,-122.4008',
        noaa_url         => 'http://marine.weather.gov/MapClick.php?lat=37.3231&lon=-122.4008',
    },
);


sub curl_get {
    my $url = shift;
    my $ua  = Mojo::UserAgent->new;

    my $res = $ua->max_redirects(5)
                 ->get($url)->result;
    if ( $res->is_success ) {
        return $json->decode($res->body), 'nil';
    }
    elsif ( $res->is_error ) {
        return 'nil', $res->code . ' ' . $res->message;
    }
    #my $response_body;

    #my $curl = WWW::Curl::Easy->new();

    #$curl->setopt(CURLOPT_HEADER,0);
    #$curl->setopt(CURLOPT_USERAGENT, 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0');
    #$curl->setopt(CURLOPT_WRITEDATA,\$response_body);

    #$curl->setopt(CURLOPT_URL, $url);

    #my $retcode       = $curl->perform;
    #my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

    #if ( $response_code =~ /^2\d+/smx ) {
    #    return $json->decode($response_body), 'nil';
    #}
    #else {
    #    return 'nil', $retcode.' '.$curl->strerror($retcode).' '.$curl->errbuf;
    #}
}

sub get_urls {
    my $loc = shift;

    my ($response, $err) = curl_get($forcast_locations{$loc}->{base_url});

    if ( $err eq 'nil' ) {
        $forcast_locations{$loc}->{forcast_url}      = $response->{properties}->{forecast};
        $forcast_locations{$loc}->{forcast_grid_url} = $response->{properties}->{forecastGridData};
    }
    else {
        $forcast_locations{$loc}->{forcast_url}            = 'nil';
        $forcast_locations{$loc}->{forcast_grid_url}       = 'nil';
        $forcast_locations{$loc}->{forcast_url_error}      = $err;
        $forcast_locations{$loc}->{forcast_grid_url_error} = $err;
    }

    return;
}

sub get_current {
    my $loc = shift;

    my ($response, $err) = curl_get($forcast_locations{$loc}->{forcast_grid_url});

    if ( $err eq 'nil' ) {
        my $temp           = shift @{ $response->{properties}->{temperature}->{values} };
        my $weather        = shift @{ $response->{properties}->{weather}->{values} };
        my $temp_low       = shift @{ $response->{properties}->{minTemperature}->{values} };
        my $temp_high      = shift @{ $response->{properties}->{maxTemperature}->{values} };
        my $wind_speed     = shift @{ $response->{properties}->{windSpeed}->{values} };
        my $gust_speed     = shift @{ $response->{properties}->{windGust}->{values} };
        my $wind_direction = shift @{ $response->{properties}->{windDirection}->{values} };
        my $precip         = shift @{ $response->{properties}->{probabilityOfPrecipitation}->{values} };


        my $current_weather = shift @{ $weather->{value} };

        $forcast_locations{$loc}->{current}->{temperature} = ( $temp->{value} * 1.8 + 32 ); ## convert C to F
        $forcast_locations{$loc}->{current}->{minTemperature} = ( $temp_low->{value} * 1.8 + 32 );
        $forcast_locations{$loc}->{current}->{maxTemperature} = ( $temp_high->{value} * 1.8 + 32 );

        $forcast_locations{$loc}->{current}->{windSpeed} = ( $wind_speed->{value} * 2.2369 ); ## convert meters/second to mph
        $forcast_locations{$loc}->{current}->{windGust} = ( $gust_speed->{value} * 2.2369 );

        $forcast_locations{$loc}->{current}->{probabilityOfPrecipitation} = $precip->{value};

        if ( ( defined $current_weather->{coverage} ) and ( defined $current_weather->{weather} )) {
            $forcast_locations{$loc}->{current}->{weather}     = $current_weather->{coverage}.' '.$current_weather->{weather};
        }
        else {
            $forcast_locations{$loc}->{current}->{weather} = '';
        }

        if ( ( ( $precip->{value} ge 0 ) and (  $precip->{value} le 22.5 ) ) or ( ( $precip->{value} ge 337.5 ) and ( $precip->{value} le 360 ) ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'North';
        }
        elsif ( ( $precip->{value} gt 22.5 ) and ( $precip->{value} le 67.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'Northeast';
        }
        elsif ( ( $precip->{value} gt 67.5 ) and ( $precip->{value} le 112.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'East';
        }
        elsif ( ( $precip->{value} gt 112.5 ) and ( $precip->{value} le 157.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'Southeast';
        }
        elsif ( ( $precip->{value} gt 157.5 ) and ( $precip->{value} le  202.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'South';
        }
        elsif ( ( $precip->{value} gt 202.5 ) and ( $precip->{value} le 247.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'Southwest';
        }
        elsif ( ( $precip->{value} gt 247.5 ) and ( $precip->{value} le 292.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'West';
        }
        elsif ( ( $precip->{value} gt 292.5 ) and ( $precip->{value} lt 337.5 ) ) {
            $forcast_locations{$loc}->{current}->{windDirection} = 'Northwest';
        }

        $forcast_locations{$loc}->{current}->{detailed} = sprintf "Now: %s %.0f and %s. Low around %.0f high of %.0f. %s wind %.0f mph, with gusts as high as %.0f mph. %.0f%s chance of rain.",
            $forcast_locations{$loc}->{current}->{weather},
            $forcast_locations{$loc}->{current}->{temperature},
            $forcast_locations{$loc}->{forcast}->{temperatureTrend} || 'steady',
            $forcast_locations{$loc}->{current}->{minTemperature},
            $forcast_locations{$loc}->{current}->{maxTemperature},
            $forcast_locations{$loc}->{current}->{windDirection},
            $forcast_locations{$loc}->{current}->{windSpeed},
            $forcast_locations{$loc}->{current}->{windGust},
            $forcast_locations{$loc}->{current}->{probabilityOfPrecipitation},
            '%';

    }
    else {
        $forcast_locations{$loc}->{current}->{detailed} = 'nil';
    }

}

sub get_forecast {
    my $loc = shift;

    my ($response, $err) = curl_get($forcast_locations{$loc}->{forcast_url});

    if ( $err eq 'nil' ) {
        my $forcast = shift @{ $response->{properties}->{periods} };
        $forcast_locations{$loc}->{forcast}->{icon}             = $forcast->{icon};
        $forcast_locations{$loc}->{forcast}->{detailedForecast} = $forcast->{detailedForecast};
        $forcast_locations{$loc}->{forcast}->{startTime}        = $forcast->{startTime};
        $forcast_locations{$loc}->{forcast}->{endTime}          = $forcast->{endTime};
        $forcast_locations{$loc}->{forcast}->{temperatureTrend} = $forcast->{temperatureTrend};
        $forcast_locations{$loc}->{forcast}->{name}             = $forcast->{name};

    }
    else {
        $forcast_locations{$loc}->{forcast}->{icon}             = 'nil';
        $forcast_locations{$loc}->{forcast}->{detailedForecast} = 'nil';
        $forcast_locations{$loc}->{forcast}->{startTime}        = 'nil';
        $forcast_locations{$loc}->{forcast}->{endTime}          = 'nil';
        $forcast_locations{$loc}->{forcast}->{temperatureTrend} = 'nil';
        $forcast_locations{$loc}->{forcast}->{name}             = 'nil';
        $forcast_locations{$loc}->{forcast_err}                 = $err;
    }

    return;
}

sub get_tides_forecast {
    my $loc = shift;

    my ($response, $err) = curl_get($forcast_locations{$loc}->{tide_forcast_url});

    if ( $err eq 'nil' ) {
        @{ $forcast_locations{$loc}->{tide_forcast} } = @{ $response->{predictions} };
    }
    else {
        push @{ $forcast_locations{$loc}->{tide_forcast} }, { t => 'nil', type => 'nil', v => 'nil' },
                                                            { t => 'nil', type => 'nil', v => 'nil' },
                                                            { t => 'nil', type => 'nil', v => 'nil' },
                                                            { t => 'nil', type => 'nil', v => 'nil' };
        $forcast_locations{$loc}->{tide_forcast_err} = $err;
    }
}

sub get_alerts {
    my $loc = shift;
	my @alerts;

    my ($response, $err) = curl_get($forcast_locations{$loc}->{alerts_url});

	if ( $err eq 'nil' ) {
        if ( scalar @{ $response->{features} }> 0 ) {
		    for my $alert ( @{ $response->{features} } ) {
		    	my @tmp_alert;

                if ( ( defined $alert->{properties}->{headline} ) or ( defined $alert->{properties}->{instruction} ) ) {
    	    		push @tmp_alert, $alert->{properties}->{headline};
	        		push @tmp_alert, $alert->{properties}->{instruction};
                }
                push @alerts, \@tmp_alert;
            }
        }
        else {
            push @alerts, [ 'No active alerts.' ];
        }


		@{ $forcast_locations{$loc}->{alerts} } = @alerts;
	}
	else {
		push @alerts, 'nil';
		@{ $forcast_locations{$loc}->{alerts} } = @alerts;
		$forcast_locations{$loc}->{alerts_err}  = $err;
	}
}

for my $location ( keys %forcast_locations ) {
    get_urls($location);
    get_forecast($location);
    get_current($location);
    get_tides_forecast($location);
    get_alerts($location);
}


print <<EOF;
<style>
table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
}
th, td {
    padding: 5px;
    text-align: left;
}
</style>

<table style="width:100%">
EOF

for my $loc ( keys %forcast_locations ) {

    print <<EOF;
<tr>
    <th colspan="4"><a href="$forcast_locations{$loc}->{noaa_url}">$forcast_locations{$loc}->{name}</a></th>
</tr>
<tr>
    <th><img src="$forcast_locations{$loc}->{forcast}->{icon}"</th>
    <td colspan="4">$forcast_locations{$loc}->{forcast}->{name}: $forcast_locations{$loc}->{forcast}->{detailedForecast}</td>
</tr>
<tr>
    <th>Current conditions</th>
    <td colspan="4">$forcast_locations{$loc}->{current}->{detailed}</td>
</tr>
<tr>
EOF
print '    <th rowspan="'.scalar @{$forcast_locations{$loc}->{tide_forcast}}.'">Tides</th>';
    for my $tide_data ( @{$forcast_locations{$loc}->{tide_forcast}} ) {
        print <<EOF;
    <th>$tide_data->{t}</th>
    <td>$tide_data->{type}: $tide_data->{v} feet</td>
</tr>
EOF
    }
print <<EOF;
<tr>
    <th>Alerts</th>
EOF
    for my $alert ( @{$forcast_locations{$loc}->{alerts}} ) {
            print <<EOF;
    <td colspan="4">@{$alert}</td>
EOF
    }
print <<EOF;
</tr>
<tr>
    <td colspan="4"></th>
</tr>
EOF
}

print '</table>'."\n";

for my $loc ( keys %forcast_locations ) {
    for my $key ( grep /err/smx, %{ $forcast_locations{$loc} } ) {
            print $loc.' - '.$key.': '.$forcast_locations{$loc}->{$key}."<br>\n";
    }
}

##partial base_url_output
#"properties" => {
#    "fireWeatherZone"     => "https://api.weather.gov/zones/fire/CAZ529",
#    "forecast"            => "https://api.weather.gov/gridpoints/MTR/94,88/forecast",
#    "forecastGridData"    => "https://api.weather.gov/gridpoints/MTR/94,88",
#    "forecastHourly"      => "https://api.weather.gov/gridpoints/MTR/94,88/forecast/hourly",
#    "forecastOffice"      => "https://api.weather.gov/offices/MTR",
#    "forecastZone"        => "https://api.weather.gov/zones/forecast/CAZ529",
#  },

##forcast
#    forcast => {
#      detailedForecast => "Patchy fog after 11pm. Mostly cloudy, with a low around 55. Southeast wind 2 to 18 mph, with gusts as high as 23 mph.",
#      endTime => "2018-08-15T06:00:00-07:00",
#      icon => "https://api.weather.gov/icons/land/night/fog?size=medium",
#      isDaytime => bless(do{\(my $o = 0)}, "JSON::PP::Boolean"),
#      name => "Tonight",
#      number => 1,
#      shortForecast => "Patchy Fog",
#      startTime => "2018-08-14T19:00:00-07:00",
#      temperature => 55,
#      temperatureTrend => undef,
#      temperatureUnit => "F",
#      windDirection => "SE",
#      windSpeed => "2 to 18 mph",
#    },

##tide forcast
#  predictions => [
#    { t => "2018-08-14 07:17", type => "L", v => -0.142 },
#    { t => "2018-08-14 13:53", type => "H", v => 4.912 },
#    { t => "2018-08-14 19:39", type => "L", v => 1.513 },
#    { t => "2018-08-15 01:35", type => "H", v => 4.889 },
#  ],
