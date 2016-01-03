# encoding: utf-8
require 'sass'
require_relative '../sass-cmyk.rb'

describe "Sass CMYK object" do

  it "should be successfully instantiated with CMYK values" do
     cmyk_color = Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>20, :yellow=>30, :black=>40})
     cmyk_color.class.should == Sass::Script::Value::CMYK
  end

  it "should raise an error when instantiated with one or more CMYK values missing" do
    expect{ Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>0, :yellow=>3})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (over 100) for one or more CMYK components" do
    expect{ Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>0, :yellow=>3, :black=>120})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (less than 0) for one or more CMYK components" do
    expect{ Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>0, :yellow=>-2, :black=>100})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (non-integer) for one or more CMYK components" do
    expect{ Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>0, :yellow=>20.5, :black=>100})}.to raise_error(ArgumentError)
  end

  describe "instance methods" do
    
    before(:each) do
      @dummy_color = Sass::Script::Value::CMYK.new({:cyan=>20, :magenta=>40, :yellow=>60, :black=>70})
      @dummy_color_already_normalized = Sass::Script::Value::CMYK.new({:cyan=>0, :magenta=>30, :yellow=>10, :black=>20})
    end

    it "should be able to return its attrs" do
      @dummy_color.attrs.should == {:cyan=>20, :magenta=>40, :yellow=>60, :black=>70}
    end

    it "should be able to return Cyan component percentage" do
      @dummy_color.cyan.should == 20
    end

    it "should be able to return Magenta component percentage" do
      @dummy_color.magenta.should == 40
    end

    it "should be able to return Yellow component percentage" do
      @dummy_color.yellow.should == 60
    end

    it "should be able to return Black (K) component percentage" do
      @dummy_color.black.should == 70
    end

    it "should convert to String as CSS function in format cmyk(nn%,nn%,nn%,nn%)" do
      @dummy_color.to_s.should == "cmyk(20%,40%,60%,70%)"
    end

    it "should be able to normalize CMYK color components (C+M+Y => K) (in place)" do
      @dummy_color.normalize!
      @dummy_color.attrs.should == {:cyan=>0, :magenta=>20, :yellow=>40, :black=>90}
    end

    it "should be able to normalize CMYK color components (C+M+Y => K) (returning new CMYK color)" do
      new_color = @dummy_color.normalize
      new_color.attrs.should == {:cyan=>0, :magenta=>20, :yellow=>40, :black=>90}
    end

    it "should not change CMYK color components when normalizing (in place) in cases where 1 or more components has zero value" do
      @dummy_color_already_normalized.normalize!
      @dummy_color_already_normalized.attrs.should == {:cyan=>0, :magenta=>30, :yellow=>10, :black=>20}
    end

    it "should not change CMYK color components when normalizing (returning new CMYK color) in cases where 1 or more components has zero value" do
      new_color = @dummy_color_already_normalized.normalize
      new_color.should == @dummy_color_already_normalized
    end

    it "should be able to add a CMYK color to itself and return a new color" do
      color1 = Sass::Script::Value::CMYK.new({:cyan=>25, :magenta=>50, :yellow=>0, :black=>0})
      color2 = Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>10, :yellow=>0, :black=>0})
      color1.plus(color2).attrs.should == {:cyan=>35, :magenta=>60, :yellow=>0, :black=>0}
    end

    it "should max out CMYK values at 100% when adding two colors" do
      color1 = Sass::Script::Value::CMYK.new({:cyan=>75, :magenta=>50, :yellow=>0, :black=>0})
      color2 = Sass::Script::Value::CMYK.new({:cyan=>30, :magenta=>10, :yellow=>0, :black=>0})
      color1.plus(color2).attrs.should == {:cyan=>100, :magenta=>60, :yellow=>0, :black=>0}
    end

    it "should normalize resulting color when adding two colors" do
      color1 = Sass::Script::Value::CMYK.new({:cyan=>75, :magenta=>50, :yellow=>0, :black=>0})
      color2 = Sass::Script::Value::CMYK.new({:cyan=>30, :magenta=>0, :yellow=>20, :black=>0})
      color1.plus(color2).attrs.should == {:cyan=>80, :magenta=>30, :yellow=>0, :black=>20}
    end

    it "should raise an error when adding something other than a CMYK color to itself" do
      expect{ @dummy_color.plus(2) }.to raise_error(ArgumentError)    
    end

    it "should raise an error when subtracting something from itself" do
      expect{ @dummy_color.minus(@dummy_color_already_normalized) }.to raise_error(NoMethodError)
    end

    it "should be able to scale down CMYK color component values by multiplying by a scalar value" do
      scalar_val = Sass::Script::Value::Number.new(0.1)
      @dummy_color_already_normalized.times(scalar_val).attrs.should == {:cyan=>0, :magenta=>3, :yellow=>1, :black=>2}
    end

    it "should be able to scale up CMYK color component values by multiplying by a scalar value" do
      scalar_val = Sass::Script::Value::Number.new(1.2)
      @dummy_color_already_normalized.times(scalar_val).attrs.should == {:cyan=>0, :magenta=>36, :yellow=>12, :black=>24}
    end

    it "should be able to scale down CMYK color component values by multiplying by a scalar value, and normalize results" do
      scalar_val = Sass::Script::Value::Number.new(0.5)
      @dummy_color.times(scalar_val).attrs.should == {:cyan=>0, :magenta=>10, :yellow=>20, :black=>45}
    end

    it "should be able to scale up CMYK color component values by multiplying by a scalar value, and normalize results" do
      scalar_val = Sass::Script::Value::Number.new(1.1)
      @dummy_color.times(scalar_val).attrs.should == {:cyan=>0, :magenta=>22, :yellow=>44, :black=>99}
    end

    it "should raise an error when scaling up CMYK colors proportionally would result in at least one component over 100%" do
      scalar_val = Sass::Script::Value::Number.new(1.5)
      expect{ @dummy_color.times(scalar_val)}.to raise_error(ArgumentError)
    end

    it "should raise an error when multiplied by anything other than a number" do
      expect{ @dummy_color.times(@dummy_color_already_normalized) }.to raise_error(ArgumentError)
    end

  end
  
end
