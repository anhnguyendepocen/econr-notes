

library(Rcpp)
library(inline)


inc = '
#include <blitz/array.h>
'

src = '
using namespace blitz;
Rcpp::NumericVector A(A_);
Rcpp::NumericVector A2(A2_);

// read dimension attribute of R arrays
Rcpp::IntegerVector d1 = A.attr("dim");
Rcpp::IntegerVector d2 = A2.attr("dim");

// create 2 blitz cubes B and B2
// supply contents of dim vectors manually
blitz::Array<double,3> B(A.begin(), shape(d1(0),d1(1),d1(2)), neverDeleteData);
blitz::Array<double,3> B2(A2.begin(), shape(d2(0),d2(1),d2(2)), neverDeleteData);

// do some blitz arithmethic
blitz::Array<double,3> C(d1(0),d1(1),d1(2));
C = B + B2;

// copy the result back to B (which is a view of A, i.e. will contain the same data)
B = C;

// return array
return wrap(A);
'

A = array(1:60,c(2,5,6))
A2 = array(120:60,c(2,5,6))

f = cxxfunction(signature(A_="numeric",A2_="numeric"),body=src,plugin="Rcpp",includes=inc)
all.equal(f(A,A2),A+A2)
