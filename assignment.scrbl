#lang scribble/manual
@require[scribble-math]
@require[scribble-math/dollar]
@require[racket/runtime-path]

@require["../../lib.rkt"]
@define-runtime-path[hw-file "hw11.lean"]


@title[#:tag "hw11" #:style (with-html5 manual-doc-style)]{Homework 11}

@bold{Released:} @italic{Wednesday, March 29, 2023 at 6:00pm}

@bold{Due:} @italic{Wednesday, April 5, 2023 at 6:00pm}

@nested[#:style "boxed"]{
What to Download:

@url{https://github.com/logiccomp/s23-hw11/raw/main/hw11.lean}
}

Please start with this file, filling in where appropriate, and submit your homework to the @tt{hw11} assignment on Gradescope. This page has additional information, and allows us to format things nicely.

@bold{To do this assignment in the browser: @link["https://github.com/codespaces/new?machine=basicLinux32gb&repo=578247893&location=EastUs&ref=main&devcontainer_path=.devcontainer%2Fdevcontainer.json"]{Create a Codespace}.}



@section{Problem 1: Proving with Classical Logic}

In this problem, you will prove various theorems, some of which require an axiom from classical logic, @lean{Classical.em}, and others do not! 

@minted-file-part["lean" "0" hw-file]


@section{Returning to specifications}
In the remaining problems, you will write definitions and theorems,
but @bold{no proofs}. We are moving back towards focusing on 
@italic{specification}, rather than @italic{proof}, which has been our focus for the past six weeks. While one secondary goal of this class was to expose you to various methods of proof, the primary goal was to learn how to think about specifications, and how to reason formally about behavior of programs.

@section{Problem 2: Red Black Trees}

A red-black balanced binary search tree is a binary search tree that uses the following invariant to ensure that it remains balanced, and as a result, operations on it remain fast. 

It is defined as follows:

@itemlist[#:style 'unordered
          (list (item "Each node has a color (red or black) associated with it (in addition to its value and left and right children)")
                (item "A node can be 'null': these will form the leaves of the tree."))]

Further, the following three properties hold:

@itemlist[#:style 'unordered
        (list (item "(root property) The root of the red-black tree is black")
            (item "(red property) The children of a red node are black.")
            (item "(black property) For each node with at least one null child, the number of black nodes on the path from the root to the null child is the same."))]


As a binary search tree, all left children are @italic{less} than right children. Elements will be natural numbers, in our case.

Your task is to:

@itemlist[#:style 'ordered
(list (item "Design an inductive type RedBlackTree. It should have Nat's as values. Use the empty inductive type below to start.")
(item "Given the (blank) definitions for empty (to create an empty tree), insert (to insert a new number to the tree) & delete (to remove a number), write theorems that ensure that the properties hold. Note that you do not need to _prove_ the theorems, just write down what they are."))]

@minted-file-part["lean" "1" hw-file]

@section{Problem 3: Information Flow}


Throughout most of the semester, we have been concerned with software
@italic{correctness}: i.e., how to ensure that a particular function, given
some input, produces a given output. That's not, however, the only 
type of property that we might want our programs to satisfy. One 
other example that we've seen is constant timeness: we had a problem
in HW3, where we wanted to ensure not that a password checking 
function worked (correctness), but that it took the same amount of
time regardless of input. 

Another class of properties that we may want to ensure are so-called
information flow properties: certain data may originate from specific
sources, and it is possible that it should not end up being passed 
to other sources. e.g., most websites have a notion of user-specific 
data, and most should not be shared with other users outside of 
specific purposes. 

One interesting example: in 2011, Facebook had a bug where by 
reporting a person's @bold{public} photo for abuse, the system would 
then show additional @bold{private} photos to see if you wanted to 
add them to your report (@link["https://www.zdnet.com/article/facebook-flaw-allows-access-to-private-photos/"]{https://www.zdnet.com/article/facebook-flaw-allows-access-to-private-photos/}). 
The only @italic{bug}, though it was serious, is that photos that 
person should not have been given access to were shown to them! 
Otherwise, the code all worked fine...

In this problem, you will write a theorem statement that ensures 
that a (unspecified) function @tt{process} does not leak any private 
information. Private information, in this case, is the first 
argument to the function (@tt{private_inputs}); the function also has 
another argument, @tt{public_inputs}, that does not need to remain 
private. 

Note that you need to think about _how_ the private inputs could 
potentially leak: you don't know what the definition of the function 
is, so what theorem can you write about it that nonetheless ensures 
that if users see the _output_ of it they cannot determine anything 
about the private inputs.

@minted-file-part["lean" "2" hw-file]


@section{Problem 4: Algorithmic Fairness}


Another example of a property of systems that is not correctness,
but nonetheless is important for the behavior of systems is 
@bold{algorithmic fairness}: i.e., ensuring that computer systems do 
not encode bias. A well-known example is that computer vision 
algorithms have historically performed much worse on people with 
darker skin than people with lighter skin. Once noticed, this is 
obviously a problem (and, compounded by how facial detection is 
often deployed, but that's a separate issue), but how do we ensure 
that this doesn't happen? 

One way, beyond merely testing on more representative datasets 
(which should certainly be done), is to specify how the behavior of 
code should connect (or not connect) to properties of the inputs. 
In the example of computer vision, training/testing data would need 
to be labeled by skin color, but once that was done, a specification 
like the following could be expressed:

@leanblock{
let samples = all labeled input images
let light_skin = filter(light skin, samples)
let dark_skin = filter(dark skin, samples)
count(filter(recognize, light_skin)) / count(light_skin) =
count(filter(recognize, dark_skin)) / count(dark_skin)
}

i.e., we want to ensure that the @tt{recognize} algorithm performs 
similarly on both subsets of the input data. Of course, it may be 
that getting identical results is impossible, but by writing such a 
specification, and validating (via proof or testing), we surface 
this behavior. If not identical, perhaps we get them both to be in 
the same range:

@leanblock{
0.7 < count(filter(recognize, light_skin)) / count(light_skin) < 0.8
0.7 < count(filter(recognize, dark_skin)) / count(dark_skin) < 0.8
}

If we had a way to generate data, we could do this kind of testing
with the same property-based testing techniques as we used at the 
beginning of the semester.

For example, you might define a generator:

@leanblock{
Generate10k : forall A, Generator A -> Generator [A]
}

That creates a list of 10,000 elements of a given element.

Then you could write a specification function that, given a list
of elements, returned what fraction passed the recognition function.

Other problems are easier to specify and deal with than images, 
and yet still have the same important consequences for fairness. 

In this problem, we want you to come up with a specification, this
time for the problem of Mortgage Lending. 

At this point, whether people are given mortgages (home loans) is 
significantly impacted by algorithms, that take as inputs all sorts 
of data about the potential lenders and deside whether (and at what 
rate) to give loans. It's been shown that people from minority
groups are denied loans at higher rates, or given higher interest
rates even if they are given loans (see, e.g., @link["https://news.mit.edu/2022/machine-learning-model-discrimination-lending-0330"]{https://news.mit.edu/2022/machine-learning-model-discrimination-lending-0330}). 

Such algorithms are trained on data, selected from various sources, 
and itself possibly encoding various biases. Indeed, housing 
discrimination has a long history (see, e.g., redlining). How can we 
ensure that a given decision procedure is fair? 

Clearly, we could label data like the above example with images
and test that the algorithm doesn't do better or worse with 
people of certain races, and unlike with images, we can actually
permute data easily: we could run the algorithm once, then change
the race (for example) and run it again and see if things change. 

With that idea in mind, in this problem you are tasked with 
writing a theorem that _proves_ that there is no bias in a 
particular function that decides whether to give mortgages. 
It's up to you both to decide _what that means_ and how to ensure it.

Consider that you have a function, @tt{give_mortgage} that takes
as input @tt{income} (a list of yearly income, going back several 
years), @tt{assets} (number), @tt{race}, @tt{gender}, @tt{age}, 
@tt{zipcode} (where they currently live), and returns a boolean 
of whether or not to give a mortgage.

Write a theorem that ensures that @tt{give_mortgage} does not 
encode bias. Think about how you might express that? How is this 
similar or different from, e.g., the information flow problem above?

@minted-file-part["lean" "3" hw-file]