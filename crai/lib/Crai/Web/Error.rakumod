unit module Crai::Web::Error;

use Crai::Web::Layout;
use Template::Classic;

my &template-error := template :(:$description!), q:to/HTML/;
    <p><%= $description %></p>
    HTML

my sub render-error(|c)
    is export
{
    template-error(|c);
}

my sub respond-error(Int() $status)
    is export
{
    constant %errors := {
        0   => (｢Unknown error｣, ｢Something went wrong.｣),
        404 => (｢Not found｣, ｢The page you were looking for does not exist.｣),
    };

    my ($title, $description) := %errors{$status} // %errors{0};
    sub content { render-error(:$description) }

    return (
        $status,
        { Content-Type => 'text/html' },
        render-layout(:$title, :&content),
    );
}
