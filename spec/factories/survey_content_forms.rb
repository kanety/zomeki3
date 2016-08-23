FactoryGirl.define do
  time_now = Time.now

  factory :survey_content_form_1, class: 'Survey::Content::Form' do
    site_id 1
    concept_id 1
    state 'public'
    model 'Survey::Form'
    code 'SF1'
    name 'アンケート１'
    note 'アンケート１のメモ'
    created_at time_now
    updated_at time_now
  end

  factory :survey_content_form_2, class: 'Survey::Content::Form' do
    site_id 1
    concept_id 1
    state 'public'
    model 'Survey::Form'
    code 'SF2'
    name 'アンケート２'
    note 'アンケート２のメモ'
    created_at time_now
    updated_at time_now
  end
end
