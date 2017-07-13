require "spec_helper"

context "when unauthenticated" do
  describe server(:sensu1) do
    describe capybara("http://sensu1:3000") do
      it "returns 401" do
        visit "/datacenters"
        expect(page.status_code).to eq 401
      end
    end
  end
end

context "when authenticated" do
  describe server(:sensu1) do
    describe capybara("http://sensu1:3000") do
      it "shows events page" do
        visit "/#/login"
        find(:xpath, '//input[@name="user"]').set("admin")
        find(:xpath, '//input[@name="pass"]').set("password")
        find(:xpath, '//button[@type="submit"]').click
        expect(page).to have_content("admin")
        expect(page).to have_content("EVENTS")
        expect(page.status_code).to eq 200
        # page.save_screenshot "screenshot.png"
      end
    end
  end
end
