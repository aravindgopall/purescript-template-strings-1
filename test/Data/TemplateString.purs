module Test.Data.TemplateString where

import Prelude (Unit, discard, (==))
import Effect (Effect)

import Test.Unit (test, suite)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (assert, equal)
import Data.TemplateString.Unsafe ((<~>))
import Data.TemplateString ((<^>))

import Data.Tuple.Nested


main :: Effect  Unit
main = runTest do
  suite "Unsafe" do
    test "template" do
      assert "single" ("Hello, ${name}!" <~> { name: "Mr. Foo" } == "Hello, Mr. Foo!")
      assert "multi" ("Hello, ${fName} ${lName}!" <~> { fName: "Foo", lName: "Bar" } == "Hello, Foo Bar!")

  suite "Safe" do
    test "template" do
      assert "single" ("Hello, ${name}!" <^> ["name" /\ "Mr. Foo"] == "Hello, Mr. Foo!")
      assert "multi" ("Hello, ${fName} ${lName}!" <^> ["fName" /\ "Foo", "lName" /\ "Bar"] == "Hello, Foo Bar!")

  suite "Injection safe" do
    test "no past-dependent substitutions" do
      -- the value being templated in shouldn't affect other substitutions
      let built = "${one} => ${two}" <^> ["one" /\ "${two}", "two" /\ "bar"]
      let expected = "${two} => bar"
      -- specifically that the above isn't `"bar => bar"`
      equal expected built

  suite "Malicious keys" do
    test "do no harm" do
      equal "42" ("${__proto__}" <^> ["__proto__" /\ "42"])

