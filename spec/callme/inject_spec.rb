require 'spec_helper'

# Ensures that :inject keyword works as it should
describe "Object.inject" do
  class ContactBook
    include Callme::Inject
    inject :contacts_repository
    inject :validator, ref: :contact_validator
  end
  class ContactBookService
    include Callme::Inject
    inject :contacts_repository
    inject :validator, ref: :contact_validator
  end
  class ContactsRepository
  end
  class ContactValidator
  end

  let(:container) do
    Callme::Container.new do |c|
      c.dep(:contacts_repository,  class: ContactsRepository)
      c.dep(:contact_validator,    class: ContactValidator)
      c.dep(:contact_book,         class: ContactBook)
      c.dep(:contact_book_service, class: "ContactBookService")
    end
  end

  it "should autowire dependencies" do
    container[:contact_book].contacts_repository.should be_a(ContactsRepository)
    container[:contact_book].validator.should be_a(ContactValidator)
  end

  it "should lazy autowire dependencies for string class names" do
    container[:contact_book_service].contacts_repository.should be_a(ContactsRepository)
    container[:contact_book_service].validator.should be_a(ContactValidator)
  end

  it "should raise ArgumentError if non-symbol passed as dependency name" do
    expect do
      class SomeClass
        include Callme::Inject
        inject 'bar'
      end
    end.to raise_error(ArgumentError, "dependency name should be a symbol")
  end

  it "inject should define instance variable" do
    container[:contact_book].instance_variable_get(:@contacts_repository).should be_a(ContactsRepository)
  end

  it "inject should not define class variable" do
    expect do
      container[:contact_book].class.contacts_repository
    end.to raise_error(NoMethodError)
  end

end
