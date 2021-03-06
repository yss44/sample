require 'spec_helper'

describe "StaticPages" do
  subject{page}

  shared_examples_for"all static pages" do
    it{should have_selector('h1',text:heading)}
    it{should have_selector('title',text:full_title(page_title))}
  end

   it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    page.should have_selector 'title', text: full_title('')
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end

  describe "Home page" do
    before{visit root_path}
    let(:heading){"Sample App"}
    let(:page_title){""}

    it_should_behave_like "all static pages"
    it {should_not have_selector('title',text:"| Home")}

    context "for signed_in users" do
      let(:user){FactoryGirl.create(:user)}
      before do
        FactoryGirl.create(:micropost,user:user,content:"c1")
        FactoryGirl.create(:micropost,user:user,content:"c2")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}",text:item.content)
        end
      end

      describe "sidebar" do
        it{should have_selector('aside span',text:"#{user.microposts.count} #{"micropost".pluralize}")}
      end

      describe "feed" do
        before(:all){30.times{FactoryGirl.create(:micropost,user:user)}}
        after(:all){User.delete_all}
  
        it{should have_selector("div.pagination")}
  
        it "has pagination" do
          user.feed.paginate(page: 1).each do |post|
            page.should have_selector('li',text:post.content)
          end
        end
      end
    end
  end

  describe "Help page" do
    before{visit help_path}
    let(:heading){"Help"}
    let(:page_title){"Help"}
    
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before{visit about_path}
    let(:heading){"About Us"}
    let(:page_title){"About Us"}

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before{visit contact_path}
    let(:heading){"Contact"}
    let(:page_title){"Contact"}

    it_should_behave_like "all static pages"
  end

end
